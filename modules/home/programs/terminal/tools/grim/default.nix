{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.terminal.tools.grim; 
in
{
  options.bautinix.home.programs.terminal.tools.grim = {
    enable = mkEnableOption "grim";
  };

  config = mkIf cfg.enable {

    programs.grim = {
      enable = true;
    }; 
  };
}
