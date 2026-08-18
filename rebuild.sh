#!/usr/bin/env bash
# Sync flake to /etc/nixos and rebuild (no git filter — /etc/nixos is not a git repo).
set -euo pipefail

SRC="${HOME}/dotfiles/nixosConfig"
ETC="/etc/nixos"

if [ ! -f "${SRC}/flake.nix" ]; then
  echo "Missing ${SRC}/flake.nix" >&2
  exit 1
fi

if [ ! -f "${SRC}/hardware-configuration.nix" ]; then
  echo "Missing ${SRC}/hardware-configuration.nix — run: sudo nixos-generate-config" >&2
  exit 1
fi

echo "==> Sync ${SRC} -> ${ETC}"
if [ -L "${ETC}" ]; then
  echo "/etc/nixos is a symlink — remove it first: sudo rm /etc/nixos" >&2
  exit 1
fi

sudo mkdir -p "${ETC}"
sudo rsync -a --delete \
  --exclude '.git/' \
  --exclude 'flake.lock' \
  --exclude '*.sh' \
  --exclude '*.txt' \
  --exclude 'README.md' \
  --exclude 'FLAKES.md' \
  "${SRC}/" "${ETC}/"

echo "==> nixos-rebuild switch (from ${ETC}, no git filter)"
cd "${ETC}"
sudo nixos-rebuild switch --flake "path:${ETC}#hp-nixos" "$@"

echo "Done."
