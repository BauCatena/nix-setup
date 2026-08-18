{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.playerctl; 
in
{
  options.bautinix.home.programs.graphical.addons.playerctl = {
    enable = mkEnableOption "playerctl";
  };
}
