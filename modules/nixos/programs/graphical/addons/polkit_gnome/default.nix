{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.polkit_gnome;
in
{
  options.bautinix.programs.graphical.addons.polkit_gnome = {
    enable = mkEnableOption "polkit_gnome";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      polkit_gnome
    ];
    };
}
