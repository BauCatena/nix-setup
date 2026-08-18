{ ... }:

{
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.interactiveShellInit = ''
    export PATH="/run/wrappers/bin:/run/current-system/sw/bin:$PATH"
    if [ -z "''${KITTY_WINDOW_ID:-}" ] && [ "''${TERM:-}" = "xterm-kitty" ]; then
      export TERM=xterm-256color
    fi
  '';
}
