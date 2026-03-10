# Bug Bounty Draft - POST /student-services/api/v2/timetables/query-student-timetable-in-range

- Time: 2026-03-10T16:50:11.343657Z
- Host: erp.usth.edu.vn
- Severity (heuristic): **MEDIUM**
- Risk score: **5**

## Findings
- **idor** (5): Matched pattern(s) for idor

## Suggested Next Tests
- Đổi object ID sang user khác và so sánh response.
- Thử object cũ sau khi đổi phiên đăng nhập.
