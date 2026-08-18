#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

fn="${1:?usage: qs_ipc.sh <function> [args...]}"
shift

QS_SHELL="${QS_CONFIG_PATH:-$HOME/.config/quickshell/shell.qml}"
LOG="${XDG_RUNTIME_DIR:-/tmp}/qs-ipc.log"

try_ipc() {
    local desc="$1"
    shift
    local out rc
    out=$(timeout 2 "$@" 2>&1) && rc=0 || rc=$?
    printf '%s\n> %s\n%s\n(exit %s)\n\n' "$(date -Iseconds)" "$desc" "$out" "$rc" >>"$LOG"
    [ "$rc" -eq 0 ] && return 0
    return 1
}

: >"$LOG"

if ! pgrep -x quickshell >/dev/null 2>&1; then
    echo "quickshell is not running" >&2
    exit 1
fi

# Quickshell IPC flag order varies by version — try all common forms
if try_ipc "ipc -p call" quickshell ipc -p "$QS_SHELL" call qsIpc "$fn" "$@"; then exit 0; fi
if try_ipc "--path ipc call" quickshell --path "$QS_SHELL" ipc call qsIpc "$fn" "$@"; then exit 0; fi
if try_ipc "-p ipc call" quickshell -p "$QS_SHELL" ipc call qsIpc "$fn" "$@"; then exit 0; fi
if try_ipc "ipc call (path env)" env QS_CONFIG_PATH="$QS_SHELL" quickshell ipc call qsIpc "$fn" "$@"; then exit 0; fi
if try_ipc "ipc call (no path)" quickshell ipc call qsIpc "$fn" "$@"; then exit 0; fi

echo "IPC failed — log: $LOG" >&2
tail -8 "$LOG" >&2
exit 1
