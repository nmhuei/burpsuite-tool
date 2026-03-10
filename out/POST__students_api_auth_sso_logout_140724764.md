# Bug Bounty Draft - POST /students/api/auth/sso/logout

- Time: 2026-03-10T17:03:49.250448Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **MEDIUM**
- Risk score: **5**

## Findings
- **idor** (5): Matched pattern(s) for idor

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
