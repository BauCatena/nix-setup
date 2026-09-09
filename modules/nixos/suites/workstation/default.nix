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
        sddm.enable = true;
      };
      programs = {
        graphical = {
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


