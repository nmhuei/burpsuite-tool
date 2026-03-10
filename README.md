# Burpsuite Tool (Burp Bridge)

Bridge nhẹ để lấy request/response từ Burp Suite, phân tích heuristic, và xuất báo cáo Markdown.

> Repo: `nmhuei/burpsuite-tool`

---

## 1) Tổng quan nhanh

Tool gồm 3 phần chính:

1. **Burp extension (`burp_extender.py`)**
   - chạy bên trong Burp Suite (Jython)
   - export traffic HTTP ra file JSONL

2. **Pipeline phân tích**
   - `collector.py` → normalize input
   - `analyzer.py` → chấm heuristic theo `rules.yaml`
   - `reporter.py` → xuất markdown report

3. **Script chạy nhanh**
   - `run_mvp.sh`: chạy pipeline mẫu
   - `auto_timetable.sh`: pipeline mở rộng

---

## 2) Cài từ đầu (clean setup)

### Yêu cầu
- Python 3.10+
- Burp Suite (Community hoặc Professional)
- Java runtime (cho Burp)
- Jython standalone jar (để Burp load Python extension)

### Cài package Python

```bash
cd /home/light/Downloads/burpsuite-tool
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
# Nếu repo có requirements thì dùng:
# pip install -r requirements.txt
```

Hiện tại script chủ yếu dùng stdlib, nên thường không cần thêm nhiều package.

---

## 3) Mở Burp Suite + gắn extension

### Bước A — Mở Burp

Ví dụ trên Linux:

```bash
burpsuite
```

hoặc chạy từ file `.sh` Burp bạn tải về.

### Bước B — Cấu hình Jython

1. Vào **Extensions → Installed → Add**
2. Chọn:
   - **Extension type**: `Python`
   - **Extension file**: `burp_extender.py` (trong repo này)
3. Nếu Burp báo thiếu Python runtime:
   - vào **Extensions → Python Environment**
   - trỏ tới `jython-standalone-*.jar`

### Bước C — Verify extension

- Tab output của extension phải không có stacktrace đỏ
- Burp không báo `Failed to load extension`

---

## 4) Luồng chạy chuẩn

### 4.1 Thu traffic từ Burp

- Bật proxy/Intercept như bình thường
- Cho request chạy qua Burp
- Extension ghi log ra file (theo cấu hình trong `burp_extender.py`)

### 4.2 Chạy pipeline phân tích

```bash
cd /home/light/Downloads/burpsuite-tool
source .venv/bin/activate
./run_mvp.sh
```

Hoặc chạy tay từng bước:

```bash
python3 collector.py   <input-jsonl> > out/collected.json
python3 analyzer.py    out/collected.json rules.yaml > out/findings.json
python3 reporter.py    out/findings.json > out/report.md
```

---

## 5) File quan trọng

- `burp_extender.py` — extension Burp
- `collector.py` — ingest/normalize
- `analyzer.py` — heuristic engine
- `reporter.py` — xuất report markdown
- `rules.yaml` — rule tuning
- `out/` — output artifacts

---

## 6) Cách chỉnh rule nhanh

Sửa `rules.yaml` để:
- tăng/giảm độ nhạy
- thêm pattern header/body đáng ngờ
- đổi mức severity

Sau khi sửa, chạy lại `analyzer.py` + `reporter.py`.

---

## 7) Troubleshooting

### Burp không load extension
- Kiểm tra Jython đã trỏ đúng jar chưa
- Kiểm tra path `burp_extender.py` đúng repo chưa
- Mở tab Errors trong Extensions để đọc traceback

### Không thấy output trong `out/`
- kiểm tra extension có ghi file chưa
- đảm bảo script có quyền ghi thư mục
- chạy thử `./run_mvp.sh` rồi kiểm tra log console

### Report trống
- có thể input không có request hợp lệ
- kiểm tra định dạng JSONL đầu vào
- tăng logging trong `collector.py`

---

## 8) Chạy nhanh 1 lệnh

```bash
cd /home/light/Downloads/burpsuite-tool
source .venv/bin/activate
./run_mvp.sh
```

Sau đó đọc kết quả trong thư mục `out/`.

---

## 9) Gợi ý workflow thực tế

1. Mở Burp + load extension
2. Crawl/scan ứng dụng mục tiêu trong phạm vi cho phép
3. Export/stream traffic
4. Chạy analyzer + reporter
5. Review findings theo severity và retest

---

Nếu muốn, mình có thể viết thêm `run_full.sh` để tự:
- kiểm tra env,
- tạo `out/` sạch,
- chạy pipeline,
- in đường dẫn report cuối cùng cho nhanh demo.
