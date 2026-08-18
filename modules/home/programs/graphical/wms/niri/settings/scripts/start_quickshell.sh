#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

LOG="${XDG_RUNTIME_DIR:-/tmp}/quickshell.log"
READY="${XDG_RUNTIME_DIR:-/tmp}/quickshell.ready"
QS="${QS_CONFIG_PATH:-$HOME/.config/quickshell/shell.qml}"

if pgrep -f '[q]uickshell.*shell\.qml' >/dev/null 2>&1; then
    exit 0
fi

"$SCRIPT_DIR/cleanup_stale_helpers.sh" || true
pkill -x quickshell 2>/dev/null || true
sleep 0.2

rm -f "$READY"
nohup quickshell --path "$QS" >>"$LOG" 2>&1 &
disown

for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    sleep 0.15
    if [ -f "$READY" ]; then
        exit 0
    fi
done

notify-send -a niri -t 3000 "Quickshell" "Failed to start — see $LOG" 2>/dev/null || true
exit 1
