#!/usr/bin/env bash
# Emergency recovery on hp-nixos (run from TTY Ctrl+Alt+F3 or SSH)
set -euo pipefail

DOTFILES="${HOME}/dotfiles"

echo "=== 1. Symlinks ==="
mkdir -p ~/.config ~/.local
for d in niri quickshell tofi foot fish; do
  [ -d "$DOTFILES/$d" ] || continue
  if [ -e "$HOME/.config/$d" ] && [ ! -L "$HOME/.config/$d" ]; then
    mv "$HOME/.config/$d" "$HOME/.config/${d}.bak-$(date +%s)"
  fi
  ln -sfn "$DOTFILES/$d" "$HOME/.config/$d"
  echo "  ~/.config/$d -> $(readlink -f ~/.config/$d)"
done
if [ -d "$DOTFILES/bin" ]; then
  ln -sfn "$DOTFILES/bin" "$HOME/.local/bin"
fi

echo
echo "=== 2. Script permissions ==="
chmod +x "$DOTFILES/niri/scripts/"*.sh "$DOTFILES/bin/"*.sh 2>/dev/null || true

echo
echo "=== 3. Validate niri ==="
if niri validate --config "$HOME/.config/niri/config.kdl" 2>&1; then
  echo "  niri config OK"
else
  echo "  niri config INVALID — fix before relogin"
fi

echo
echo "=== 4. Disable quickshell autostart temporarily (safe mode) ==="
AUTOSTART="$HOME/.config/niri/modules/autostart.kdl"
if [ -f "$AUTOSTART" ] && ! grep -q "SAFE MODE" "$AUTOSTART"; then
  cp "$AUTOSTART" "${AUTOSTART}.full"
  cat > "$AUTOSTART" <<'EOF'
// SAFE MODE — quickshell disabled until session works
spawn-sh-at-startup "$HOME/.config/niri/scripts/set_wallpaper.sh $HOME/.config/niri/wallpaper/minimal.jpg"
spawn-sh-at-startup "$HOME/.config/niri/scripts/run.sh foot --server"
spawn-sh-at-startup "$HOME/.config/niri/scripts/run.sh wlsunset -T 5000"
EOF
  echo "  autostart -> safe mode (no quickshell)"
  echo "  restore: cp ${AUTOSTART}.full ${AUTOSTART}"
fi

echo
echo "=== 5. Wallpaper ==="
"$DOTFILES/niri/scripts/set_wallpaper.sh" "$DOTFILES/niri/wallpaper/minimal.jpg" 2>/dev/null || \
  awww img "$DOTFILES/niri/wallpaper/minimal.jpg" 2>/dev/null || true

echo
echo "=== DONE ==="
echo "Now: logout from SDDM and login session 'niri' again."
echo "Test: Super+T (foot), Super+E (yazi)"
echo "When OK, restore full autostart:"
echo "  cp ~/.config/niri/modules/autostart.kdl.full ~/.config/niri/modules/autostart.kdl"
echo "  relogin, then: quickshell --path ~/.config/quickshell/shell.qml &"
