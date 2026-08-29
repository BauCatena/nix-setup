{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.terminal.tools.gcc; 
in
{
  options.bautinix.programs.terminal.tools.gcc = {
    enable = mkEnableOption "gcc";
  };
}
