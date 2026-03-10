# Bug Bounty Draft - GET /students/api/remote-configs/transcript

- Time: 2026-03-10T16:50:11.023682Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **MEDIUM**
- Risk score: **5**

## Findings
- **idor** (5): Matched pattern(s) for idor

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
