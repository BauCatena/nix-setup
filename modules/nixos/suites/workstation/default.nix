{ config, pkgs, lib,  ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.workstation;
in
{
  options.bautinix.suites.workstation = {
    enable = lib.mkEnableOption "workstation suite";
  };

  config = mkIf cfg.enable {
    bautinix = lib.mkForce {

    programs.graphical.apps.qemu.enable = true;
      display-managers = {
        sddm.enable = true;
      };
      services = {
        printing = {
          enable = true;
        };
      };
      programs = {
        graphical = {
          apps = {
            steam.enable = true;
          };
          desktops = {
            plasma  = {
              enable = true;
            };
          };
        };
      };
    };
  };
}


