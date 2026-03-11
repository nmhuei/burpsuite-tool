#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASE_DIR"
mkdir -p out

if [ -d .venv ]; then
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

if ! python3 -c "import yaml" >/dev/null 2>&1; then
  echo "❌ Thiếu dependency: pyyaml"
  echo "👉 Chạy: python3 -m venv .venv && source .venv/bin/activate && pip install pyyaml"
  exit 1
fi

export BURP_BRIDGE_HOST=${BURP_BRIDGE_HOST:-127.0.0.1}
export BURP_BRIDGE_PORT=${BURP_BRIDGE_PORT:-8765}
echo "🌸 Starting Burp Bridge on http://${BURP_BRIDGE_HOST}:${BURP_BRIDGE_PORT}"
python3 collector.py
