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
