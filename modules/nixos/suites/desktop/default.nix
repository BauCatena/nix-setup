{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.desktop;
in
{
  options.bautinix.suites.desktop = {
    enable = lib.mkEnableOption "desktop enviorment";
  };


  config = mkIf cfg.enable {

    bautinix = {
      programs = {
        graphical = {
          addons = {
            awww.enable = true;
            brightnessctl.enable = true;
            polkit_gnome.enable = true;
          };
          wms = {
            niri.enable = true;
          };
        };
      };
      display-managers = {
        sddm = {
          enable = true;
        };
      };
    };
  };
}
