{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.graphical.apps.spotify;
in
{
  options.bautinix.home.programs.graphical.apps.spotify = {
    enable = mkEnableOption "spotify";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      spotify
    ];

  };
}
