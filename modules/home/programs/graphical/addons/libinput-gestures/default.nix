{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.libinput-gestures; 
in
{
  options.bautinix.home.programs.graphical.addons.libinput-gestures = {
    enable = mkEnableOption "libinput-gestures";
  };
}
