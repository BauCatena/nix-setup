{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.browsers.firefox; 
in
{
  options.bautinix.programs.graphical.browsers.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      firefox
    ];

    programs.firefox = {
      enable = true;
    };

  };
}
