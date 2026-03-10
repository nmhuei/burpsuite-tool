from __future__ import annotations
import re

def _contains_any(text, patterns):
    t = (text or '').lower()
    return any((p or '').lower() in t for p in patterns)

def analyze_request(event, rules):
    method = (event.get('method') or 'GET').upper()
    path = event.get('path') or '/'
    query = event.get('query') or ''
    headers = {str(k).lower(): str(v) for k, v in (event.get('headers') or {}).items()}
    body = event.get('body') or ''
    joined = f"{path}?{query}\n{body}"

    findings = []
    weights = rules.get('risk_weights', {})
    for cat, pats in (rules.get('patterns') or {}).items():
        if _contains_any(joined, pats):
            findings.append({'category': cat, 'score': int(weights.get(cat, 1)), 'reason': f'Matched pattern(s) for {cat}'})

    if method in {'PUT', 'PATCH', 'DELETE'} and re.search(r'/\d+', path):
        findings.append({'category': 'idor', 'score': int(weights.get('idor', 1)), 'reason': 'State-changing method on numeric object path'})

    sensitive = []
    for key in (rules.get('sensitive_keys') or []):
        if key in headers or re.search(rf'"?{re.escape(key)}"?\s*[:=]', body, re.I):
            sensitive.append(key)
    if sensitive:
        findings.append({'category': 'sensitive_data_exposure', 'score': int(weights.get('sensitive_data_exposure', 1)), 'reason': f"Sensitive key(s): {', '.join(sorted(set(sensitive)))}"})

    score = sum(f['score'] for f in findings)
    severity = 'high' if score >= 8 else 'medium' if score >= 4 else 'low'

    ideas = []
    cats = {f['category'] for f in findings}
    if 'idor' in cats:
        ideas += ['Đổi object ID sang user khác và so sánh response.', 'Thử object cũ sau khi đổi phiên đăng nhập.']
    if 'auth_bypass' in cats:
        ideas += ['Thử bỏ/đổi Authorization và role-related headers.']
    if 'ssrf' in cats:
        ideas += ['Thử callback/url tới endpoint kiểm soát của bạn để xác nhận outbound request.']
    if not ideas:
        ideas = ['Chạy baseline checks: authz, validation, error leakage, rate limit.']

    return {'risk_score': score, 'severity': severity, 'findings': findings, 'next_tests': ideas[:5]}
