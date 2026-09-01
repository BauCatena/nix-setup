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
    bautinix.theme.qt = {
      icon = {
        name = "Nordzy-dark";
        package = pkgs.nordzy-icon-theme;
      };

      theme =
        let
          qtThemeName =
            if cfg.variant == "darker" then
              "Nordic-Darker"
            else if cfg.variant == "bluish" then
              "Nordic-bluish"
            else
              "Nordic";
        in
        {
          name = qtThemeName;
          package = pkgs.nordic;
        };
    };
  };
}
