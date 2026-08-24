{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.wl-clipboard; 
in
{
  options.bautinix.home.programs.graphical.addons.wl-clipboard = {
    enable = mkEnableOption "wl-clipboard";
  };
    config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      wl-clipboard
    ];
  };
}
