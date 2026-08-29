{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.obsidian;
in
{
  options.bautinix.programs.graphical.apps.obsidian = {
    enable = mkEnableOption "obsidian";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      obsidian
    ];

    programs.obsidian = {
      enable = true;
    };
  };
}
