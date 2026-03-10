from __future__ import annotations
from datetime import datetime

def build_report(event, analysis):
    out = []
    out.append(f"# Bug Bounty Draft - {event.get('method','GET')} {event.get('path','/')}")
    out.append(f"\n- Time: {datetime.utcnow().isoformat()}Z")
    out.append(f"- Host: {event.get('host','unknown')}")
    out.append(f"- Severity (heuristic): **{analysis.get('severity','low').upper()}**")
    out.append(f"- Risk score: **{analysis.get('risk_score',0)}**\n")
    out.append('## Findings')
    fs = analysis.get('findings') or []
    out += [f"- **{f.get('category')}** ({f.get('score')}): {f.get('reason')}" for f in fs] or ['- No strong signal yet.']
    out.append('\n## Suggested Next Tests')
    out += [f"- {x}" for x in (analysis.get('next_tests') or [])]
    return '\n'.join(out) + '\n'
