{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.browsers.firefox; 
in
{
  options.bautinix.programs.graphical.browsers.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {

    programs.firefox = {
      enable = true;
    };

  };
}
