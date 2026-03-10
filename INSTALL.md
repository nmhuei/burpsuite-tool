# Install & Run (Burpsuite Tool)

## 1) Requirements

- Python 3.10+
- Burp Suite (Community/Pro)
- Jython standalone jar (for Python extension in Burp)

## 2) Start bridge

```bash
cd /home/light/Downloads/burpsuite-tool
./run_mvp.sh
```

Bridge endpoint: `http://127.0.0.1:8765/ingest`

## 3) Load Burp extension

1. Burp → Extender → Extensions → Add
2. Extension type: `Python`
3. Extension file: `burp_extender.py`
4. If Burp asks Jython path, set Jython jar in Burp settings first.

## 4) Verify

- Browse target through Burp proxy.
- Check generated outputs in `out/`.

## 5) One-command timetable update

```bash
./auto_timetable.sh
```

This will:
- replay latest captured timetable request,
- fetch full timetable payload,
- parse + normalize,
- update Emiu timetable files under `/home/light/Documents/timetable/emiu/`.

## Troubleshooting

- `Connection refused 127.0.0.1:8765` → run `./run_mvp.sh`.
- `No module named yaml` → `pip install pyyaml` (or use project venv).
- No timetable found → open timetable page once in Burp-browser flow, then rerun.
