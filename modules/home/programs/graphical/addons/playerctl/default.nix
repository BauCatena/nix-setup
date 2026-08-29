{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.playerctl; 
in
{
  options.bautinix.programs.graphical.addons.playerctl = {
    enable = mkEnableOption "playerctl";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
    playerctl
    ];
  };
}
