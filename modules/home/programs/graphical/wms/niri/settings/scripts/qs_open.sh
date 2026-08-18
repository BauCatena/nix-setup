#!/usr/bin/env bash
# Niri → Quickshell one-way trigger (no keyboard layer in QS).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

cmd="${1:?usage: qs_open.sh <command> [arg...]}"
shift
trigger="${XDG_RUNTIME_DIR:-/tmp}/quickshell.cmd"

qs_running() {
    pgrep -x quickshell >/dev/null 2>&1 && return 0
    pgrep -f '[q]uickshell.*shell\.qml' >/dev/null 2>&1 && return 0
    [ -f "${XDG_RUNTIME_DIR:-/tmp}/quickshell.ready" ] && return 0
    return 1
}

if ! qs_running; then
    "$SCRIPT_DIR/start_quickshell.sh" || true
fi

if [ "$#" -gt 0 ]; then
    printf '%s\t%s\n' "$cmd" "$*" > "$trigger"
else
    printf '%s\n' "$cmd" > "$trigger"
fi

for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ ! -f "$trigger" ] && exit 0
    sleep 0.08
done

notify-send -a niri -t 2500 "Quickshell" "No response — restart quickshell" 2>/dev/null || true
exit 1
