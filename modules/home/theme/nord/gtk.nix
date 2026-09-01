{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bautinix.theme.nord;

  gtkThemeName =
    if cfg.variant == "darker" then
      "Nordic-darker"
    else if cfg.variant == "bluish" then
      "Nordic-bluish-accent"
    else if cfg.variant == "polar" then
      "Nordic-Polar"
    else
      "Nordic";
in
{
  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        name = gtkThemeName;
        package = pkgs.nordic;
      };
      iconTheme = {
        name = "Nordzy-dark";
        package = pkgs.nordzy-icon-theme;
      };
    };
  };
}
