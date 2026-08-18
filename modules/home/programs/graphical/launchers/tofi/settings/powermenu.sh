#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.config/niri/scripts/env.sh"

options=$'Suspend\nLock\nReboot\nShutdown\nLogout'
choice=$(printf '%s\n' "$options" | tofi --config "$HOME/.config/tofi/configpowermenu") || exit 0
[ -n "$choice" ] || exit 0

case "$choice" in
    Shutdown) systemctl poweroff ;;
    Lock) swaylock -c "$HOME/.config/niri/swaylock.conf" ;;
    Reboot) systemctl reboot ;;
    Suspend) swaylock -c "$HOME/.config/niri/swaylock.conf" & sleep 1; systemctl suspend ;;
    Logout) niri msg action quit skip-confirmation=true ;;
esac
