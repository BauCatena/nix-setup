{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.addons.grim;
in
{
  options.bautinix.home.programs.graphical.addons.grim = {
    enable = mkEnableOption "grim";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      grim
    ];
  };

}
