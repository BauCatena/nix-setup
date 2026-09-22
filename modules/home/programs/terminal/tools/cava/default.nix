{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.tools.cava;
in
{
  options.bautinix.programs.terminal.tools.cava = {
    enable = mkEnableOption "cava";
  };

  config = mkIf cfg.enable {
    programs.cava.enable = true;
  };
}
