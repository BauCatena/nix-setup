#!/usr/bin/env bash
set -uo pipefail # drop -e, or scope it carefully — don't let killall/pgrep kill the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

WALLPAPER="${1:-$HOME/dotfiles/packages/wallpapers/assets/nord/nixos.png}"
PERSIST=1

if [ "${1:-}" = "--no-persist" ]; then
  PERSIST=0
  shift
  WALLPAPER="${1:-$HOME/.config/niri/wallpaper/minimal.jpg}"
fi
WALLPAPER="${WALLPAPER/#\~/$HOME}"

export XDG_CACHE_HOME="${XDG_RUNTIME_DIR:-/tmp}/awww-xdg-cache"
export AWWW_CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/awww-cache"
mkdir -p "$XDG_CACHE_HOME" "$AWWW_CACHE_DIR"

SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/wayland-1-awww-daemon.sock"

ensure_daemon() {
  systemctl --user start awww.service 2>/dev/null || true
  for i in $( # up to 5s
    seq 1 50
  ); do
    [ -S "$SOCK" ] && return 0
    sleep 0.1
  done
  echo "awww-daemon socket never appeared" >&2
  return 1
}

persist_wallpaper() {
  local path="$1"
  local theme stored
  theme=$(grep -oE 'switch_theme\.sh \([^)]+\)' "$HOME/.config/niri/theme.kdl" 2>/dev/null |
    sed -n 's/.*(\(.*\))/\1/p' | head -1)
  theme="${theme% preview}"
  [ -n "$theme" ] || theme="minimal"
  if [[ "$path" == "$HOME/"* ]]; then
    stored="~/${path#$HOME/}"
  else
    stored="$path"
  fi
  for conf in "$HOME/.config/niri/theme.conf" "$HOME/.config/niri/themes/${theme}.conf"; do
    [ -f "$conf" ] || continue
    if grep -q '^\$wallpaper' "$conf"; then
      sed -i "s|^\\\$wallpaper =.*|\$wallpaper = ${stored}|" "$conf"
    fi
  done
  echo "$stored" >"$HOME/.config/niri/wallpaper.state"
}

if [ "$WALLPAPER" = "black" ]; then
  WALLPAPER=""
fi
if [ -n "$WALLPAPER" ] && [ ! -f "$WALLPAPER" ]; then
  fallback="$HOME/.config/niri/wallpaper/minimal.jpg"
  [ -f "$fallback" ] && WALLPAPER="$fallback" || WALLPAPER=""
fi

if ! command -v awww >/dev/null 2>&1; then
  echo "awww not found in PATH" >&2
  exit 0
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
  ensure_daemon || exit 1
  awww clear 000000 2>&1 || true
  exit 0
fi

ensure_daemon || {
  echo "could not reach awww-daemon" >&2
  exit 1
}

if ! awww img "$WALLPAPER" --transition-type simple -- --no-cache 2>&1; then
  echo "first awww img attempt failed, retrying" >&2
  awww img "$WALLPAPER" --transition-type none 2>&1 || {
    echo "awww img failed for $WALLPAPER" >&2
    exit 1
  }
fi

[ "$PERSIST" -eq 1 ] && persist_wallpaper "$WALLPAPER"
