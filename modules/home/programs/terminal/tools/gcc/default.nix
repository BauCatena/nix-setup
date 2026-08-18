{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.terminal.tools.gcc; 
in
{
  options.bautinix.home.programs.terminal.tools.gcc = {
    enable = mkEnableOption "gcc";
  };
}
