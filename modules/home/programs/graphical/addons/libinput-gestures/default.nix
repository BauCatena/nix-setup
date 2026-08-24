{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.libinput-gestures; 
in
{
  options.bautinix.home.programs.graphical.addons.libinput-gestures = {
    enable = mkEnableOption "libinput-gestures";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      libinput-gestures
    ];
  };

}
