{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.libreoffice;
in
{
  options.bautinix.programs.graphical.apps.libreoffice = {
    enable = mkEnableOption "libreoffice";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      libreoffice
    ];
  };
}
