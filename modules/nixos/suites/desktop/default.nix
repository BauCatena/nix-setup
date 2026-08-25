{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.nixos.suites.desktop;
in
{
  options.bautinix.nixos.suites.desktop = {
    enable = lib.mkEnableOption "desktop enviorment";
  };


  config = mkIf cfg.enable {

    bautinix.nixos = {
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
        sddm.enable = true;
      };
    };
  };
}
