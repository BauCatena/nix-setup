{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.terminal.tools.ssh; 
in
{
  options.bautinix.programs.terminal.tools.ssh = {
    enable = mkEnableOption "openssh";
  };

  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      openssh
    ];

    programs.ssh = {
      enable = true;
    }; 
  };
}
