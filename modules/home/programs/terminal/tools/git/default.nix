{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.terminal.tools.git; 
in
{
  options.bautinix.programs.terminal.tools.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {

    programs.git = {
      enable = true;
    }; 
  };
}
