{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.programs.graphical.addons.polkit_gnome;
in
{
  options.bautinix.nixos.programs.graphical.addons.polkit_gnome = {
    enable = mkEnableOption "polkit_gnome";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      polkit_gnome
    ];
    };
}
