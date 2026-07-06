#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/common.sh"
[ "$(detect_platform)" = "wsl2" ] || { echo "FAIL: attendu wsl2"; exit 1; }
[ "$MEETILY_IDENTIFIER" = "com.meetily.ai" ] || { echo "FAIL: identifier"; exit 1; }
[ "$MEETILY_DATA_DIR" = "$HOME/.local/share/com.meetily.ai" ] || { echo "FAIL: data dir"; exit 1; }
echo "OK common.sh"
