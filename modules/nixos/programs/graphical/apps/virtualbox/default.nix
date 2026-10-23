{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.virtualbox;
in
{
  options.bautinix.programs.graphical.apps.virtualbox = {
    enable = mkEnableOption "virtualbox";
  };

  config = mkIf cfg.enable {

    programs.virtualbox = {
      enable = true;
    };
  };
}
