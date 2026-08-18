#!/usr/bin/env bash
# Kill orphaned helpers left behind by crashed/restarted sessions.
set -euo pipefail

pkill -f '[q]uickshell\.cmd.*while true' 2>/dev/null || true
pkill -f '[s]mart_volume\.sh' 2>/dev/null || true
pkill -f '[s]mart_brightness\.sh' 2>/dev/null || true
pkill -f '[/]niri/scripts/osd\.sh' 2>/dev/null || true

# Keep a single mail poller; autostart will start one if needed.
mapfile -t _mail_pids < <(pgrep -f '[m]ail_poll\.py' 2>/dev/null || true)
if ((${#_mail_pids[@]} > 1)); then
    for pid in "${_mail_pids[@]:0:${#_mail_pids[@]}-1}"; do
        kill "$pid" 2>/dev/null || true
    done
fi
