#!/usr/bin/env bash
# Pre-rebuild fixes for the modular flake at nixosConfig/nixosConfig/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="${HOME}/dotfiles"

echo "==> Flake root: $ROOT"
echo "==> Rebuild: $ROOT/switch.sh"

if [ -x "$DOTFILES/nixosConfig/restore-dotfiles-symlinks.sh" ]; then
  echo "==> Ensure ~/.config symlinks (optional pre-step)"
  "$DOTFILES/nixosConfig/restore-dotfiles-symlinks.sh" || true
fi

if [ -x "$DOTFILES/nixosConfig/clean-hm-bak.sh" ]; then
  echo "==> Remove stale .hm-bak chains under modules/home"
  find "$ROOT/modules/home" \( -name '*.hm-bak' -o -name '*.hm-bak.*' \) -delete 2>/dev/null || true
fi

chmod +x "$DOTFILES/niri/scripts/"*.sh "$DOTFILES/bin/"*.sh 2>/dev/null || true

echo "==> nixos-rebuild switch"
"$ROOT/switch.sh"

echo
echo "Done. Verify: readlink -f ~/.config/quickshell ~/.config/niri"
