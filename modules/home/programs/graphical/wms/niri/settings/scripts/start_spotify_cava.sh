#!/usr/bin/env bash
# Optional audio bars for the Spotify island (SPOTIFY_CAVA=1).
set -euo pipefail
[ "${SPOTIFY_CAVA:-0}" = "1" ] || exit 0
command -v cava >/dev/null 2>&1 || exit 0

fifo="${XDG_RUNTIME_DIR:-/tmp}/spotify.cava.fifo"
out="${XDG_RUNTIME_DIR:-/tmp}/spotify.bars"
conf="${HOME}/.config/quickshell/spotify.cava.conf"
[ -f "$conf" ] || exit 0

rm -f "$fifo" "$out"
mkfifo "$fifo" 2>/dev/null || true

# cava raw output -> normalize to comma-separated bar heights for spotify_poll.py
cava -p "$conf" 2>/dev/null | while IFS= read -r line; do
    [ -n "$line" ] || continue
    # raw ascii line: semicolon-separated bar values
    echo "$line" | tr ';' '\n' | head -5 | paste -sd, - > "$out"
done
