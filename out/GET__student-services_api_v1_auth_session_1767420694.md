# Bug Bounty Draft - GET /student-services/api/v1/auth/session

- Time: 2026-03-10T16:48:15.187570Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **MEDIUM**
- Risk score: **5**

## Findings
- **idor** (5): Matched pattern(s) for idor

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
