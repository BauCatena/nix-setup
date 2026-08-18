{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.wl-clipboard; 
in
{
  options.bautinix.home.programs.graphical.addons.wl-clipboard = {
    enable = mkEnableOption "wl-clipboard";
  };
}
