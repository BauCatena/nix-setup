{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.programs.graphical.addons.btightnessctl;
in
{
  options.bautinix.nixos.programs.graphical.addons.btightnessctl = {
    enable = mkEnableOption "btightnessctl";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      btightnessctl
    ];
    };
}
