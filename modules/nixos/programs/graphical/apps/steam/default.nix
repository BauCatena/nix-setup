{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.steam;
in
{
  options.bautinix.programs.graphical.apps.steam = {
    enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Opcional: abre puertos para Steam Remote Play
      dedicatedServer.openFirewall = true; # Opcional: abre puertos para servidores dedicados
    };
  };
}
