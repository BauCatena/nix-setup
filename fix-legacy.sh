#!/usr/bin/env bash
# Remove ~/.config symlinks that point at nix store or legacy ~/dotfiles/{app}/.
# After this, switch.sh recreates direct links to modules/home/**/settings/.
set -euo pipefail

DOTFILES="${HOME}/dotfiles"
HM="${DOTFILES}/nixosConfig/nixosConfig/modules/home"
APPS=(niri quickshell tofi foot yazi fastfetch nvim nano kitty btop cava himalaya swaylock-effects)

declare -A SUBPATH=(
  [niri]=programs/graphical/wm/niri
  [quickshell]=programs/graphical/bars/quickshell
  [tofi]=programs/graphical/launchers/tofi
  [foot]=programs/terminal/emulators/foot
  [yazi]=programs/terminal/tools/yazi
  [fastfetch]=programs/terminal/tools/fastfetch
  [nvim]=programs/terminal/editors/neovim
  [nano]=programs/terminal/editors/nano
  [kitty]=programs/terminal/emulators/kitty
  [btop]=programs/terminal/tools/btop
  [cava]=programs/terminal/tools/cava
  [himalaya]=programs/terminal/tools/himalaya
  [swaylock-effects]=programs/graphical/screenlockers/swaylock-effects
)

removed=0
for app in "${APPS[@]}"; do
  dest="$HOME/.config/$app"
  expected="${HM}/${SUBPATH[$app]}/settings"
  [[ -e "$dest" || -L "$dest" ]] || continue

  if [[ -L "$dest" ]]; then
    resolved=$(readlink -f "$dest" 2>/dev/null || readlink "$dest")
    if [[ "$resolved" == "$expected" ]]; then
      echo "OK   $dest already → settings/"
      continue
    fi
  fi

  echo "REMOVE $dest"
  rm -rf "$dest"
  removed=$((removed + 1))
done

if [[ "$removed" -eq 0 ]]; then
  echo "Nothing to remove."
else
  echo "Removed $removed path(s)."
fi
echo "Run: ~/dotfiles/nixosConfig/switch.sh"
