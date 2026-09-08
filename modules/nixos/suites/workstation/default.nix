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
      display-managers = {
        gdm.enable = true;
        sddm.enable = false;
      };
      programs = {
        graphical = {
          desktop = {
            gnome  = {
              enable = true;
            };
          };
        };
      };
    };
  };
}


