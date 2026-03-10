# Bug Bounty Draft - GET /student-services/api/v1/asset-notes/student-facility-area-borrow-notes

- Time: 2026-03-10T16:50:11.505667Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **MEDIUM**
- Risk score: **5**

## Findings
- **idor** (5): Matched pattern(s) for idor

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
