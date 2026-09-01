{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bautinix.theme.nord;
in
{
  config = lib.mkIf cfg.enable {
    bautinix.theme.gtk = {
      theme =
        let
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
          name = gtkThemeName;
          package = pkgs.nordic;
        };
    };
  };
}
