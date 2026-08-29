{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.xwayland-satellite; 
in
{
  options.bautinix.programs.graphical.addons.xwayland-satellite = {
    enable = mkEnableOption "xwayland-satellite";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      xwayland-satellite
    ];
  };
}
