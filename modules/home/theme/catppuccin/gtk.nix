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
        gtk = {
          cursor = {
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursor;
            size = 24;
          };

          icon = {
            name = "Papirus-Dark";
            package = pkgs.catppuccin-papirus-folders.override {
              accent = "blue";
              flavor = "macchiato";
            };
          };

          theme = {
            name = "catppuccin-macchiato-blue-standard";
            package = pkgs.catppuccin-gtk.override {
              accents = [ "blue" ];
              variant = "macchiato";
            };
          };
        };
      };
    };
  };
}
