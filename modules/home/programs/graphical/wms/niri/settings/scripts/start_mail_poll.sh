#!/usr/bin/env bash
set -euo pipefail
CONF="${HOME}/.config/himalaya/config.toml"
[ -f "$CONF" ] || exit 0

LOCK="${XDG_RUNTIME_DIR:-/tmp}/mail_poll.lock"
exec flock -n "$LOCK" python3 "${HOME}/.config/quickshell/mail_poll.py"
