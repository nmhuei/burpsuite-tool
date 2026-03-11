#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$BASE_DIR/out"
TIMETABLE_ROOT="${TIMETABLE_ROOT:-/home/light/Documents/timetable}"
TIMETABLE_OWNER="${TIMETABLE_OWNER:-Huei}"

mkdir -p "$OUT_DIR" "$TIMETABLE_ROOT"

# 1) Ensure bridge is running
if ! ss -ltn 2>/dev/null | grep -q '127.0.0.1:8765'; then
  echo "🌸 Bridge chưa chạy, tự bật lên..."
  nohup "$BASE_DIR/run_mvp.sh" >/tmp/burp_bridge.log 2>&1 &
  sleep 1
fi

if ! ss -ltn 2>/dev/null | grep -q '127.0.0.1:8765'; then
  echo "❌ Không bật được bridge 127.0.0.1:8765"
  exit 1
fi

python3 - <<'PY'
import json, os, re, ssl, urllib.request
from pathlib import Path
from datetime import datetime, UTC

out_dir = Path('/home/light/GitHub/burpsuite-tool/out')
timetable_root = Path(os.environ.get('TIMETABLE_ROOT', '/home/light/Documents/timetable'))
owner_raw = os.environ.get('TIMETABLE_OWNER', 'Huei').strip() or 'Huei'
owner_slug = re.sub(r'[^a-z0-9]+', '-', owner_raw.lower()).strip('-') or 'unknown'
owner_dir = timetable_root / owner_slug
owner_dir.mkdir(parents=True, exist_ok=True)

# pick latest timetable request captured by Burp bridge
candidates = sorted(
    out_dir.glob('POST__student-services_api_v2_timetables_query-student-timetable-in-range_*json'),
    key=lambda p: p.stat().st_mtime,
    reverse=True,
)
req = None
for f in candidates:
    try:
        d = json.loads(f.read_text())
    except Exception:
        continue
    if not isinstance(d, dict):
        continue
    ev = d.get('event', {})
    if ev.get('kind') == 'request' and ev.get('method') == 'POST':
        req = ev
        break

if not req:
    raise SystemExit('❌ Chưa có request timetable trong out/. Hãy mở trang timetable 1 lần rồi chạy lại.')

url = req['url']
body = (req.get('body') or '').encode('utf-8')
headers = dict(req.get('headers') or {})
for k in list(headers.keys()):
    if k.lower() in ['content-length', 'host', 'accept-encoding', 'connection']:
        headers.pop(k, None)

request = urllib.request.Request(url, data=body, headers=headers, method='POST')
with urllib.request.urlopen(request, context=ssl.create_default_context(), timeout=30) as r:
    raw = r.read().decode('utf-8', errors='ignore')

# Save raw payload snapshots
(out_dir / f'{owner_slug}-timetable-live-full.json').write_text(raw)
(out_dir / 'timetable_live_full.json').write_text(raw)
arr = json.loads(raw)

slots = []
for e in arr:
    for c in (e.get('calendars') or []):
        if isinstance(c, str):
            try:
                c = json.loads(c)
            except Exception:
                continue
        dt = c.get('date')
        if isinstance(dt, (int, float)):
            dt = datetime.fromtimestamp(dt / 1000).strftime('%Y-%m-%d')
        teacher_names = c.get('teacherNames') or []
        assistant_names = c.get('assistantNames') or []
        if not teacher_names and e.get('teacherName'):
            teacher_names = [e.get('teacherName')]
        slots.append({
            'date': dt,
            'course': e.get('name') or e.get('courseName') or '',
            'courseId': e.get('courseId') or '',
            'classCode': e.get('classId') or '',
            'location': c.get('place') or '',
            'lecturer': ', '.join(teacher_names),
            'teachers': teacher_names,
            'assistants': assistant_names,
            'studentNum': e.get('studentNum'),
            'fromPeriod': c.get('from'),
            'toPeriod': c.get('to'),
            'lessonType': c.get('lessonType') or '',
            'calendarId': c.get('id'),
            'placeId': c.get('placeId'),
            'week': c.get('week'),
            'status': c.get('status')
        })

uniq = []
seen = set()
for s in slots:
    k = (s['date'], s['courseId'], s['classCode'], s['fromPeriod'], s['toPeriod'], s['location'])
    if k in seen:
        continue
    seen.add(k)
    uniq.append(s)
uniq.sort(key=lambda x: (x['date'] or '', x['fromPeriod'] or 99, x['course']))

start_map = {1:'07:30',2:'08:25',3:'09:25',4:'10:25',5:'11:20',6:'13:00',7:'13:55',8:'14:50',9:'15:50',10:'16:45',11:'18:00',12:'18:55'}
end_map   = {1:'08:20',2:'09:15',3:'10:15',4:'11:15',5:'12:10',6:'13:50',7:'14:45',8:'15:45',9:'16:40',10:'17:40',11:'18:50',12:'19:45'}

final = []
for s in uniq:
    fp, tp = s.get('fromPeriod'), s.get('toPeriod')
    final.append({
        'owner': owner_raw,
        'date': s.get('date'),
        'classCode': s.get('classCode',''),
        'courseName': s.get('course',''),
        'courseId': s.get('courseId',''),
        'course': f"{s.get('classCode','')} - {s.get('course','')} - {s.get('courseId','')}",
        'start': start_map.get(fp, ''),
        'end': end_map.get(tp, ''),
        'location': s.get('location',''),
        'lecturer': s.get('lecturer',''),
        'teachers': s.get('teachers') or [],
        'assistants': s.get('assistants') or [],
        'studentNum': s.get('studentNum'),
        'format': 'Lý thuyết' if s.get('lessonType') == 'LT' else (s.get('lessonType') or ''),
        'period': f"{fp}-{tp}" if fp and tp else '',
        'fromPeriod': fp,
        'toPeriod': tp,
        'week': s.get('week'),
        'calendarId': s.get('calendarId'),
        'placeId': s.get('placeId'),
        'status': s.get('status')
    })

(out_dir / f'{owner_slug}-timetable-parsed.json').write_text(json.dumps(uniq, ensure_ascii=False, indent=2))
(out_dir / f'{owner_slug}-timetable-parsed.md').write_text('# Timetable Parsed\n\n' + '\n'.join(
    f"- {r['date']} | tiết {r['fromPeriod']}-{r['toPeriod']} | {r['classCode']} - {r['course']} ({r['courseId']}) | {r['location']} | GV: {r['lecturer']} | SV: {r.get('studentNum')}" for r in uniq
))

month_tag = datetime.now().strftime('%Y-%m')
json_path = owner_dir / f'{owner_slug}-timetable-{month_tag}.json'
ics_path = owner_dir / f'{owner_slug}-timetable-{month_tag}.ics'
details_path = owner_dir / f'{owner_slug}-timetable-{month_tag}-details.md'
stamp = datetime.now().strftime('%Y%m%d-%H%M%S')
for path in (json_path, ics_path, details_path):
    if path.exists():
        path.with_name(path.name + f'.bak-{stamp}').write_text(path.read_text())

json_path.write_text(json.dumps(final, ensure_ascii=False, indent=2))

lines = ['BEGIN:VCALENDAR','VERSION:2.0',f'PRODID:-//OpenClaw//{owner_raw} Timetable//EN','CALSCALE:GREGORIAN']
for i, e in enumerate(final, 1):
    if not (e['date'] and e['start'] and e['end']):
        continue
    ds = e['date'].replace('-', '') + e['start'].replace(':', '') + '00'
    de = e['date'].replace('-', '') + e['end'].replace(':', '') + '00'
    lines += [
        'BEGIN:VEVENT',
        f'UID:{owner_slug}-{i}@openclaw',
        f'DTSTAMP:{datetime.now(UTC).strftime("%Y%m%dT%H%M%SZ")}',
        f'DTSTART;TZID=Asia/Ho_Chi_Minh:{ds}',
        f'DTEND;TZID=Asia/Ho_Chi_Minh:{de}',
        f'SUMMARY:{e["course"]}',
        f'LOCATION:{e["location"]}',
        f'DESCRIPTION:Owner: {owner_raw}\\nGiảng viên: {e["lecturer"]}\\nHình thức: {e["format"]}\\nTiết: {e["period"]}',
        'END:VEVENT'
    ]
lines.append('END:VCALENDAR')
ics_path.write_text('\n'.join(lines))

detail_lines = [f'# {owner_raw} Timetable Details', '']
for e in final:
    detail_lines += [
        f"## {e['classCode']} - {e['courseName']} - {e['courseId']}",
        '',
        f"- Owner: {owner_raw}",
        f"- Tiết học: {e['period']} ({e['start']}-{e['end']})",
        f"- Địa điểm: {e['location']}",
        f"- Ngày học: {e['date']}",
        f"- Giảng viên: {e['lecturer']}",
        f"- Các giảng viên: {', '.join(e.get('teachers') or [])}",
        f"- Trợ giảng: {', '.join(e.get('assistants') or [])}",
        f"- Số lượng sinh viên: {e.get('studentNum')}",
        f"- Hình thức: {e.get('format')}",
        ''
    ]
details_path.write_text('\n'.join(detail_lines))

# stable aliases for latest files per owner
latest_json = owner_dir / f'{owner_slug}-timetable-latest.json'
latest_ics = owner_dir / f'{owner_slug}-timetable-latest.ics'
latest_details = owner_dir / f'{owner_slug}-timetable-latest-details.md'
for latest, target in ((latest_json, json_path), (latest_ics, ics_path), (latest_details, details_path)):
    if latest.exists() or latest.is_symlink():
        latest.unlink()
    latest.symlink_to(target.name)

print(f'✅ Done. owner={owner_raw} raw_events={len(arr)} parsed_slots={len(uniq)} final_events={len(final)}')
print(f'📁 {owner_dir}')
print(f'📁 {json_path}')
print(f'📁 {ics_path}')
print(f'📁 {details_path}')
print(f'🔗 {latest_json}')
print(f'🔗 {latest_ics}')
print(f'🔗 {latest_details}')
PY
