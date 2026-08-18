#!/usr/bin/env bash
# Pull ~/dotfiles from hp-nixos into this Debian machine (origin repo).
# Run on Debian when you edited configs on NixOS and want them here.
#
# Usage:
#   ~/dotfiles/nixosConfig/pull-from-nixos.sh
#   ~/dotfiles/nixosConfig/pull-from-nixos.sh bauti@hp-nixos
set -euo pipefail

SRC_HOST="${1:-bauti@hp-nixos}"
SRC="${2:-/home/bauti/dotfiles}"
DEST="${3:-$HOME/dotfiles}"

echo "==> Pull $SRC_HOST:$SRC -> $DEST"
echo "    (no --delete: files only on Debian are kept)"
echo

rsync -av \
  --exclude '.git/' \
  --exclude 'VSCodium/' \
  --exclude 'mozilla/' \
  --exclude 'Cursor/' \
  --exclude '.cursor/' \
  "$SRC_HOST:$SRC/" "$DEST/"

echo
echo "==> Done. Review and commit:"
echo "    cd $DEST && git status && git diff"
