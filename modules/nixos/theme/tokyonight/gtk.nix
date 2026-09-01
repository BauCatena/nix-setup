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
    bautinix.theme.gtk = {
      theme = {
        name = "Tokyonight-Dark";
        package = pkgs.bautinix.tokyonight-gtk-theme;
      };
    };
  };
}
