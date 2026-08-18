#!/usr/bin/env bash
# One-time migration on hp-nixos: point /etc/nixos at dotfiles flake.
set -euo pipefail

DOTFILES="${HOME}/dotfiles"
NIXOS_CFG="${DOTFILES}/nixosConfig"
ETC="/etc/nixos"

if [ ! -f "${NIXOS_CFG}/flake.nix" ]; then
  echo "Missing ${NIXOS_CFG}/flake.nix — sync dotfiles first." >&2
  exit 1
fi

if [ ! -f "${NIXOS_CFG}/hardware-configuration.nix" ]; then
  if [ -f "${ETC}/hardware-configuration.nix" ]; then
    echo "==> Copy hardware-configuration.nix into dotfiles (machine-specific)"
    cp "${ETC}/hardware-configuration.nix" "${NIXOS_CFG}/hardware-configuration.nix"
  else
    echo "Missing hardware-configuration.nix — run: sudo nixos-generate-config" >&2
    exit 1
  fi
fi

echo "==> Backup /etc/nixos"
sudo cp -a "${ETC}" "${ETC}.bak.$(date +%Y%m%d-%H%M%S)"

echo "==> Sync flake config into /etc/nixos"
sudo mkdir -p "${NIXOS_CFG}/home"
sudo rsync -av --exclude 'flake.lock' \
  "${NIXOS_CFG}/" "${ETC}/" 2>/dev/null || true
sudo cp "${NIXOS_CFG}/flake.nix" "${NIXOS_CFG}/configuration.nix" "${NIXOS_CFG}/hardware-configuration.nix" "${ETC}/"
sudo cp -r "${NIXOS_CFG}/modules" "${NIXOS_CFG}/home" "${ETC}/"

echo "==> Update flake lock (needs network)"
cd "${NIXOS_CFG}"
sudo nix flake update

echo "==> Build and switch"
sudo nixos-rebuild switch --flake "${ETC}#hp-nixos"

echo
echo "==> Verify home-manager"
systemctl is-active home-manager-bauti.service && echo "home-manager: active" || echo "home-manager: inactive (normal after rebuild — check: systemctl status home-manager-bauti.service)"

echo
echo "Done. Relogin to niri."
