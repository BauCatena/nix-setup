{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.bautinix.programs.terminal.tools.btop;
in
{
  options.bautinix.programs.terminal.tools.btop = {
    enable = lib.mkEnableOption "btop";
  };

  config = mkIf cfg.enable {
    programs.btop.enable = true;

    xdg.configFile."btop" = {
    source = ./settings;
    recursive = true;
    };
  };
}
