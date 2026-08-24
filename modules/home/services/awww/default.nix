{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.services.awww;
in
{
  options.bautinix.home.services.awww = {
    enable = mkEnableOption "awww wallpaper daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.awww ];

    systemd.user.services.awww = {
      Unit = {
        Description = "Awww animated wallpaper daemon for Wayland";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
