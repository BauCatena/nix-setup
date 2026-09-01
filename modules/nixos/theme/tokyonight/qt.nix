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
    bautinix.theme.qt = {
      icon = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        name = "catppuccin-macchiato-blue";
        package = pkgs.catppuccin-kvantum.override {
          accent = "blue";
          variant = "macchiato";
        };
      };
    };
  };
}
