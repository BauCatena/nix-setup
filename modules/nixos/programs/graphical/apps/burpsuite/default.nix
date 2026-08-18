{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.programs.graphical.apps.burpsuite;
in
{
  options.bautinix.nixos.programs.graphical.apps.burpsuite = {
    enable = mkEnableOption "burpsuite";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      burpsuite
    ];
    };
}
