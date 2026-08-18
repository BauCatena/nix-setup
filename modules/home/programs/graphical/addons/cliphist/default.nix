{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.cliphist; 
in
{
  options.bautinix.home.programs.graphical.addons.cliphist = {
    enable = mkEnableOption "cliphist";
  };
}
