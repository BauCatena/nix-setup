{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bautinix.theme.tokyonight;
in
{
  config = lib.mkIf cfg.enable {
    bautinix.theme.gtk = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      icon = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "Tokyonight-Dark";
        package = pkgs.bautinix.tokyonight-gtk-theme;
      };
    };
  };
}
