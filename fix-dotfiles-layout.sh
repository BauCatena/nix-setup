#!/usr/bin/env bash
# Fix hp-nixos dotfiles layout + symlinks + permissions
set -euo pipefail

DOTFILES="${HOME}/dotfiles"

echo "=== Symlinks ==="
mkdir -p ~/.config ~/.local
for d in niri quickshell tofi foot fish bin; do
  case "$d" in
    bin) dest="$HOME/.local/bin"; src="$DOTFILES/bin" ;;
    *)   dest="$HOME/.config/$d"; src="$DOTFILES/$d" ;;
  esac
  [ -d "$src" ] || { echo "SKIP missing $src"; continue; }
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "${dest}.bak-$(date +%s)"
  fi
  ln -sfn "$src" "$dest"
  echo "OK  $dest -> $(readlink -f "$dest")"
done

echo
echo "=== Script permissions ==="
chmod +x "$DOTFILES/niri/scripts/"*.sh 2>/dev/null || true
chmod +x "$DOTFILES/bin/"*.sh 2>/dev/null || true

echo
echo "=== Required files ==="
for f in \
  niri/scripts/qs_ipc.sh \
  niri/scripts/menu.sh \
  niri/modules/keybinds.kdl \
  niri/modules/autostart.kdl \
  quickshell/shell.qml \
  bin/smart_menu.sh
do
  if [ -f "$DOTFILES/$f" ]; then
    echo "OK  $f"
  else
    echo "MISSING $f"
  fi
done

echo
echo "=== Junk at dotfiles root (safe to delete manually) ==="
find "$DOTFILES" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | while read -r f; do
  echo "  $f  (duplicate — use niri/scripts/ or bin/ instead)"
done

echo
echo "=== Test launcher ==="
if [ -x "$DOTFILES/niri/scripts/qs_ipc.sh" ]; then
  echo "Run: ~/.config/niri/scripts/qs_ipc.sh toggleAppLauncher"
else
  echo "qs_ipc.sh missing or not executable in niri/scripts/"
fi

echo
echo "=== Wallpaper ==="
echo "Run in niri session: ~/.config/niri/scripts/set_wallpaper.sh ~/.config/niri/wallpaper/minimal.jpg"
