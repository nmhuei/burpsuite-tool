# Bug Bounty Draft - GET /sso/init

- Time: 2026-03-10T17:04:15.518260Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **HIGH**
- Risk score: **15**

## Findings
- **idor** (5): Matched pattern(s) for idor
- **ssrf** (5): Matched pattern(s) for ssrf
- **sqli** (5): Matched pattern(s) for sqli

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
- Thử callback/url tới endpoint kiểm soát của bạn để xác nhận outbound request.
