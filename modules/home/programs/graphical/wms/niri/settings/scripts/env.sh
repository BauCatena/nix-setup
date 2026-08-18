# NixOS-friendly PATH for niri spawn-sh and scripts
# wrappers MUST come before current-system/sw/bin (setuid sudo lives in wrappers)
export PATH="/run/wrappers/bin:/run/current-system/sw/bin:$HOME/.local/bin:$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/share:/run/current-system/sw/share:$HOME/.local/share}"
export QS_CONFIG_PATH="${QS_CONFIG_PATH:-$HOME/.config/quickshell/shell.qml}"
export EDITOR=nvim
export VISUAL=nvim
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-niri}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-niri}"
