{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.slurp; 
in
{
  options.bautinix.home.programs.graphical.addons.slurp = {
    enable = mkEnableOption "slurp";
  };
}
