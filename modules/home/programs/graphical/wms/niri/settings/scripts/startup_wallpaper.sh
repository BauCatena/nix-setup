#!/usr/bin/env bash
# Retry wallpaper at session start — awww/niri may not be ready immediately.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

wall="$("$SCRIPT_DIR/current_wallpaper.sh")"

for _ in 1 2 3 4 5 6 8 10; do
    sleep 1
    if [ -f "$wall" ] && "$SCRIPT_DIR/set_wallpaper.sh" "$wall"; then
        exit 0
    fi
done

exit 0
