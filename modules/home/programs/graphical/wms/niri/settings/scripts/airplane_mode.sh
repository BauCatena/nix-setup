#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

if command -v nmcli >/dev/null 2>&1; then
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off
        notify-send "Airplane mode" "Wi-Fi off" 2>/dev/null || true
    else
        nmcli radio wifi on
        notify-send "Airplane mode" "Wi-Fi on" 2>/dev/null || true
    fi
elif command -v rfkill >/dev/null 2>&1; then
    rfkill toggle wifi
else
    notify-send "Airplane mode" "Install NetworkManager or rfkill." 2>/dev/null || true
fi
