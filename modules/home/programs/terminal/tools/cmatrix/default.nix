{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.terminal.tools.cmatrix; 
in
{
  options.bautinix.programs.terminal.tools.cmatrix = {
    enable = mkEnableOption "cmatrix";
  };
}
