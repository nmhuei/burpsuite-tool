<div align="center">

# 🛡️ Burpsuite Tool (Burp Bridge + Timetable Export)

**Capture HTTP traffic from Burp Suite Professional → inspect/export useful artifacts → replay timetable requests → write owner-scoped timetable files**

[Quick Start](#-quick-start) · [Burp Setup](#-burp-setup) · [Timetable Workflow](#-crawl-timetable-from-erp) · [Troubleshooting](#-troubleshooting)

</div>

---

## Burpsuite Tool là gì?

Đây là bộ bridge/pipeline để:

1. lấy traffic HTTP từ Burp extension (`burp_extender.py`),
2. ghi request/response thành file trong `out/`,
3. lọc các request timetable từ ERP,
4. replay request timetable mới nhất,
5. xuất file lịch học theo **từng owner riêng**.

Hiện repo này dùng thực tế cho workflow ERP USTH timetable qua Burp Suite Professional.

---

## 🧭 Kiến trúc pipeline

```text
Burp Suite Professional
   │
   │  (Extension: burp_extender.py)
   ▼
collector.py  -> ingest tại 127.0.0.1:8765
   ▼
out/*.json + out/*.md
   ▼
extract_timetable.py -> tìm request timetable
   ▼
auto_timetable.sh -> replay request mới nhất
   ▼
/home/light/Documents/timetable/<owner-slug>/
```

---

## ⚡ Quick Start

```bash
cd ~/GitHub/burpsuite-tool
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip pyyaml

# bật bridge ingest để Burp đẩy traffic vào repo này
./run_mvp.sh
```

Bridge endpoint:
- `http://127.0.0.1:8765/ingest`

Artifacts capture nằm ở:
- `~/GitHub/burpsuite-tool/out/`

---

## 📦 Yêu cầu hệ thống

- Linux
- Python 3.10+
- **Burp Suite Professional**
- Java runtime
- Jython standalone jar (để Burp load extension Python)

---

## 🔌 Burp Setup

### 1) Mở Burp Suite Professional

Dùng bản Pro bạn đã cài, không phải launcher Community mặc định.

### 2) Proxy listener

Trong Burp:
- **Proxy → Options**
- đảm bảo có listener:
  - `127.0.0.1:8080`

### 3) Load extension `burp_extender.py`

- **Extensions / Extender → Installed → Add**
- chọn:
  - **Extension type**: `Python`
  - **Extension file**: `~/GitHub/burpsuite-tool/burp_extender.py`

### 4) Trỏ Jython

Nếu Burp hỏi Python/Jython environment:
- `~/GitHub/burpsuite-tool/lib/jython-standalone-2.7.3.jar`

### 5) Verify

Nếu load đúng:
- tab output không có lỗi đỏ
- Burp extension gửi traffic sang `127.0.0.1:8765`
- repo sẽ bắt đầu có file mới trong `out/`

---

## 🛠️ Cách chạy chuẩn

```bash
cd ~/GitHub/burpsuite-tool
source .venv/bin/activate

# bật bridge ingest
./run_mvp.sh
```

Hoặc chạy trực tiếp:

```bash
python3 collector.py
```

---

## 📁 Cấu trúc file quan trọng

- `burp_extender.py` → Burp extension
- `collector.py` → local ingest server, nhận traffic từ Burp và ghi `out/*.json`, `out/*.md`
- `extract_timetable.py` → lọc các request timetable từ capture đã có
- `auto_timetable.sh` → replay request timetable mới nhất và export file lịch
- `analyzer.py` → heuristic/rules engine
- `reporter.py` → markdown output cho flow report
- `rules.yaml` → rule tuning
- `run_mvp.sh` → helper để bật bridge nhanh
- `out/` → capture/artifacts

---

## 📚 Crawl timetable from ERP

### 1) Bật bridge

```bash
cd ~/GitHub/burpsuite-tool
source .venv/bin/activate
./run_mvp.sh
```

### 2) Mở browser qua Burp proxy

Ví dụ Brave:

```bash
brave-browser --new-window --proxy-server='127.0.0.1:8080' 'https://erp.usth.edu.vn/students/learn/timetable'
```

### 3) Đăng nhập ERP và mở trang timetable

Khi request đi qua Burp + extension bridge, repo sẽ capture vào `out/`.

### 4) Lọc nhanh request timetable

```bash
python3 extract_timetable.py
```

### 5) Export lịch học

Owner mặc định là `Huei`:

```bash
./auto_timetable.sh
```

Chỉ định owner khác:

```bash
TIMETABLE_OWNER="Emiu" ./auto_timetable.sh
TIMETABLE_OWNER="Another Student" ./auto_timetable.sh
```

---

## 👥 Quản lý nhiều người

`auto_timetable.sh` giờ không còn hardcode một người duy nhất nữa.

Nó tự:
- nhận owner từ `TIMETABLE_OWNER`
- tạo slug tên owner
- tạo thư mục riêng theo owner
- ghi file theo tháng
- tạo alias `latest` cho mỗi owner
- giữ backup file cũ trước khi ghi đè

### Ví dụ output

Với `TIMETABLE_OWNER="Huei"`:
- `/home/light/Documents/timetable/huei/huei-timetable-2026-03.json`
- `/home/light/Documents/timetable/huei/huei-timetable-2026-03.ics`
- `/home/light/Documents/timetable/huei/huei-timetable-2026-03-details.md`
- `/home/light/Documents/timetable/huei/huei-timetable-latest.json`
- `/home/light/Documents/timetable/huei/huei-timetable-latest.ics`
- `/home/light/Documents/timetable/huei/huei-timetable-latest-details.md`

Với `TIMETABLE_OWNER="Emiu"`:
- `/home/light/Documents/timetable/emiu/...`

---

## 🧾 Dữ liệu chi tiết mỗi tiết học

Exporter hiện cố gắng lấy ra các field kiểu popup timetable:
- owner
- mã lớp
- tên môn
- mã học phần
- ngày học
- tiết học / giờ bắt đầu / giờ kết thúc
- địa điểm
- giảng viên
- danh sách giảng viên
- trợ giảng
- số lượng sinh viên
- hình thức học

File details:
- `<owner>-timetable-YYYY-MM-details.md`

---

## 🧪 Demo checklist

1. Burp Pro đã load extension thành công
2. Proxy listener `127.0.0.1:8080` đang hoạt động
3. Browser đi qua Burp proxy
4. ERP timetable request thực sự xuất hiện trong `out/`
5. `extract_timetable.py` tìm thấy request timetable
6. `auto_timetable.sh` replay thành công và tạo file trong thư mục owner

---

## 🧯 Troubleshooting

### Burp không load extension

- kiểm tra đúng file `burp_extender.py`
- kiểm tra đúng Jython jar path
- xem tab **Extensions → Errors** để đọc traceback

### Không có file mới trong `out/`

- kiểm tra bridge có đang chạy không
- kiểm tra browser có thật sự đi qua `127.0.0.1:8080` không
- kiểm tra extension đã load chưa

### `HTTP 401 Unauthorized` khi chạy `auto_timetable.sh`

Nghĩa là request timetable capture đã hết hạn session/cookie.

Cách xử lý:
- mở lại ERP qua Burp
- vào lại trang timetable
- bắt request mới còn sống
- chạy lại `./auto_timetable.sh`

### `No module named yaml`

```bash
source .venv/bin/activate
pip install pyyaml
```

---

## 🚀 Lệnh dùng hàng ngày

```bash
# bật bridge
./run_mvp.sh

# lọc request timetable đã capture
python3 extract_timetable.py

# export owner mặc định (Huei)
./auto_timetable.sh

# export cho owner cụ thể
TIMETABLE_OWNER="Emiu" ./auto_timetable.sh
```

---

## 🔐 Lưu ý an toàn

- Chỉ test trên hệ thống bạn có quyền hợp pháp
- Không dùng repo này cho mục tiêu trái phép
- File output có thể chứa dữ liệu nhạy cảm → lưu trữ cẩn thận

---

## 🤝 Project hygiene

This repo uses a lightweight professional workflow:
- Conventional commits (`feat:`, `fix:`, `docs:`...)
- PR template
- Issue templates (bug/feature)
- GitHub Actions CI (syntax + smoke checks)

See: `CONTRIBUTING.md`
