{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.libnotify; 
in
{
  options.bautinix.home.programs.graphical.addons.libnotify = {
    enable = mkEnableOption "libnotify";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
    libnotify
    ];
  };
}
