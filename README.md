<div align="center">

# 🛡️ Burpsuite Tool (Burp Bridge)

**Capture HTTP traffic from Burp Suite → analyze with rules → export clear markdown report**

[Quick Start](#-quick-start-3-phút) · [Burp Setup](#-burp-setup-chi-tiết) · [Pipeline](#-kiến-trúc-pipeline) · [Troubleshooting](#-troubleshooting)

</div>

---

## Burpsuite Tool là gì?

Đây là bộ bridge/pipeline nhỏ gọn để bạn:

1. lấy traffic HTTP từ Burp extension (`burp_extender.py`),
2. chuẩn hoá dữ liệu (`collector.py`),
3. phân tích heuristic theo `rules.yaml` (`analyzer.py`),
4. xuất báo cáo Markdown (`reporter.py`).

Mục tiêu: **đỡ làm tay**, có output rõ để review nhanh khi test web security.

---

## 🧭 Kiến trúc pipeline

```text
Burp Suite
   │
   │  (Extension: burp_extender.py)
   ▼
JSONL traffic (request/response)
   ▼
collector.py   -> normalize/clean fields
   ▼
analyzer.py    -> apply rules.yaml / scoring / findings
   ▼
reporter.py    -> out/report.md
```

---

## ⚡ Quick Start (3 phút)

```bash
cd ~/GitHub/burpsuite-tool
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip pyyaml

# chạy bridge để Burp đẩy traffic vào đây
./run_mvp.sh
```

Kết quả xem tại thư mục `out/`.

---

## 📦 Yêu cầu hệ thống

- Linux
- Python 3.10+
- Burp Suite (Community/Professional)
- Java runtime
- Jython standalone jar (để Burp load extension Python)

---

## 🔌 Burp Setup chi tiết

### 1) Mở Burp

```bash
burpsuite
```

hoặc chạy launcher Burp bạn đang dùng.

### 2) Load extension `burp_extender.py`

- vào **Extensions → Installed → Add**
- chọn:
  - **Extension type**: `Python`
  - **Extension file**: `burp_extender.py`

### 3) Trỏ Jython nếu Burp yêu cầu

- vào **Extensions → Python Environment**
- chọn file `jython-standalone-*.jar`

### 4) Verify

- tab output không có lỗi đỏ
- không có dòng `Failed to load extension`

---

## 🛠️ Cách chạy chuẩn (manual pipeline)

Sau khi Burp đã capture/export traffic:

```bash
cd ~/GitHub/burpsuite-tool
source .venv/bin/activate

# bật bridge ingest từ Burp
python3 collector.py

# hoặc chạy helper script
./run_mvp.sh
```

---

## 📁 Cấu trúc file quan trọng

- `burp_extender.py` → Burp extension
- `collector.py` → local ingest server, nhận traffic từ Burp và ghi `out/*.json`, `out/*.md`
- `analyzer.py` → heuristic/rules engine
- `reporter.py` → markdown output
- `rules.yaml` → rule tuning
- `run_mvp.sh` → chạy nhanh
- `out/` → artifacts

---

## 🧪 Demo checklist (để chắc chắn pipeline OK)

1. Burp đã load extension thành công
2. Có traffic thực sự đi qua proxy Burp
3. File input được tạo (JSONL không rỗng)
4. `collector.py` chạy không lỗi
5. `analyzer.py` có findings
6. `reporter.py` xuất `out/report.md`

---

## 🎯 Rule tuning nhanh (`rules.yaml`)

Bạn có thể chỉnh:

- mức độ nghiêm trọng (severity)
- pattern header/body đáng ngờ
- trọng số heuristic
- ngưỡng để cảnh báo

Gợi ý: chỉnh rule xong chạy lại `analyzer.py` + `reporter.py` để so kết quả trước/sau.

---

## 🧯 Troubleshooting

### Burp không load extension

- kiểm tra Jython path đúng chưa
- kiểm tra `burp_extender.py` có đúng file không
- xem tab **Extensions → Errors** để đọc traceback

### Không có output trong `out/`

- kiểm tra extension có thật sự ghi file chưa
- kiểm tra quyền ghi thư mục
- chạy `./run_mvp.sh` và xem log console

### Report trống

- input có thể rỗng / format sai
- kiểm tra JSONL đầu vào
- tăng debug print trong `collector.py`

### Findings quá nhiều false-positive

- giảm sensitivity trong `rules.yaml`
- thêm whitelist theo endpoint/header nếu cần

---

## 🚀 Lệnh dùng hàng ngày

```bash
# bật bridge để Burp gửi request/response vào repo này
./run_mvp.sh

# lọc nhanh các request timetable đã capture
python3 extract_timetable.py

# replay request timetable mới nhất và cập nhật file lịch Emiu
./auto_timetable.sh
```

---

## 🔐 Lưu ý an toàn

- Chỉ test trên hệ thống bạn có quyền hợp pháp
- Không quét/khai thác mục tiêu trái phép
- Report có thể chứa dữ liệu nhạy cảm -> lưu trữ cẩn thận

---

## 📌 Next improvements (nếu muốn mình làm tiếp)

- thêm `run_full.sh` để tự check env + validate input + generate report
- xuất HTML report đẹp hơn
- thêm score trend theo thời gian
- thêm chế độ suppress finding theo rule ID

---

Nếu bạn muốn, mình có thể viết thêm phiên bản README “for team onboarding” (siêu ngắn, 1 trang, copy-paste là chạy).
---

## 🤝 Project hygiene

This repo uses a lightweight professional workflow:
- Conventional commits (`feat:`, `fix:`, `docs:`...)
- PR template
- Issue templates (bug/feature)
- GitHub Actions CI (syntax + smoke checks)

See: `CONTRIBUTING.md`
