{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.terminal.tools.cmatrix; 
in
{
  options.bautinix.home.programs.terminal.tools.cmatrix = {
    enable = mkEnableOption "cmatrix";
  };
}
