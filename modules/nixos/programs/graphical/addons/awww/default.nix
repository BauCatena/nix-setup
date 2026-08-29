{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.awww;
in
{
  options.bautinix.programs.graphical.addons.awww = {
    enable = mkEnableOption "awww";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      awww
    ];
    };
}
