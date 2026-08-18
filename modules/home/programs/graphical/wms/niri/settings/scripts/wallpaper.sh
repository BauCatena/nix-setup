#!/usr/bin/env bash
# Set wallpaper (works via niri scripts path; bin symlink optional).
BIN="${HOME}/dotfiles/bin/wallpaper.sh"
if [ ! -x "$BIN" ]; then
    BIN="${HOME}/.local/bin/wallpaper.sh"
fi
exec "$BIN" "$@"
