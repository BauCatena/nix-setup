{
  config,
  lib,

  pkgs,
  ...
}:
let
  cfg = config.bautinix.theme.catppuccin;
in
{
  config = lib.mkIf cfg.enable {
    bautinix = {
      theme = {
        qt = {
          icon = {
            name = "Papirus-Dark";
            package = pkgs.catppuccin-papirus-folders.override {
              accent = "blue";
              flavor = "macchiato";
            };
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
    };
  };
}
