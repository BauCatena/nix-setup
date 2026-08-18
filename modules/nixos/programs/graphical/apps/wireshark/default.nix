{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.programs.graphical.apps.wireshark;
in
{
  options.bautinix.nixos.programs.graphical.apps.wireshark = {
    enable = mkEnableOption "wireshark";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      wireshark
    ];
    };
}
