{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.brightnessctl;
in
{
  options.bautinix.programs.graphical.addons.brightnessctl = {
    enable = mkEnableOption "brightnessctl";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
    };
}
