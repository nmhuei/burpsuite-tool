# Install & Run (Burpsuite Tool)

## 1) Requirements

- Python 3.10+
- Burp Suite Professional
- Jython standalone jar (for Python extension in Burp)

## 2) Start bridge

```bash
cd ~/GitHub/burpsuite-tool
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip pyyaml
./run_mvp.sh
```

Bridge endpoint: `http://127.0.0.1:8765/ingest`

## 3) Load Burp extension

1. Burp → Extender → Extensions → Add
2. Extension type: `Python`
3. Extension file: `~/GitHub/burpsuite-tool/burp_extender.py`
4. If Burp asks Jython path, set: `~/GitHub/burpsuite-tool/lib/jython-standalone-2.7.3.jar`

## 4) Verify

- Browse ERP target through Burp proxy.
- Check generated outputs in `~/GitHub/burpsuite-tool/out/`.
- If the bridge is healthy, Burp traffic will be written as `out/*.json` and `out/*.md`.

## 5) One-command timetable update

```bash
cd ~/GitHub/burpsuite-tool
./auto_timetable.sh
```

This will:
- find the latest captured timetable request,
- replay it against ERP,
- fetch the full timetable payload,
- parse + normalize it,
- update Emiu timetable files under `/home/light/Documents/timetable/emiu/`.

## Troubleshooting

- `Connection refused 127.0.0.1:8765` → run `./run_mvp.sh` first.
- `No module named yaml` → activate `.venv` and `pip install pyyaml`.
- No timetable found → open the ERP timetable page once through Burp, then rerun `./auto_timetable.sh`.
