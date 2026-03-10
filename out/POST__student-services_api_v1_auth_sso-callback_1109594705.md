# Bug Bounty Draft - POST /student-services/api/v1/auth/sso-callback

- Time: 2026-03-10T17:04:16.531993Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **HIGH**
- Risk score: **9**

## Findings
- **idor** (5): Matched pattern(s) for idor
- **sensitive_data_exposure** (4): Sensitive key(s): token

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
