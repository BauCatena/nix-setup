#!/usr/bin/env bash
set -euo pipefail
WALL_DIR="${HOME}/nix-setup/packages/wallpapers/assets/${THEME}"
[ -d "$WALL_DIR" ] || exit 0

for f in "$WALL_DIR"/*; do
  [ -f "$f" ] || continue
  case "${f,,}" in
  *.jpg | *.jpeg | *.png | *.webp)
    printf '%s\t%s\n' "$(basename "$f")" "$f"
    ;;
  esac
done | sort
