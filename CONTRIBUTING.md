# Contributing Guide

Thanks for contributing to Burpsuite Tool.

## Development setup
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
```

## Branch naming
- `feat/<short-name>`
- `fix/<short-name>`
- `docs/<short-name>`

## Commit style
Use Conventional Commits:
- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation
- `refactor:` internal refactor
- `chore:` maintenance

Examples:
- `feat: add response body entropy check`
- `fix: handle missing host in collector`

## Pull Request checklist
- [ ] Scope is small and focused
- [ ] README updated if behavior changed
- [ ] No secrets/API keys committed
- [ ] CI passes
