#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

sleep 2
firefox --new-window "about:blank" &
sleep 2

win_id=$(niri msg -j windows | jq -r '[.[] | select(.app_id == "firefox")] | last | .id // empty')
if [ -n "$win_id" ]; then
    niri msg action move-window-to-workspace --window-id "$win_id" "zenbg"
fi
