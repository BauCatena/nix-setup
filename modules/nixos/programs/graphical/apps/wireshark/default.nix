{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.wireshark;
in
{
  options.bautinix.programs.graphical.apps.wireshark = {
    enable = mkEnableOption "wireshark";
  };
  # FIXME: wireshark does not work. It return specific permission error.
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    environment.systemPackages = with pkgs; [
      wireshark
    ];
    };
}
