{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.programs.terminal.tools.gcc; 
in
{
  options.bautinix.nixos.programs.terminal.tools.gcc = {
    enable = mkEnableOption "gcc";
  };
}
