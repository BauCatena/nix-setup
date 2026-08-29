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
    home.packages = with pkgs; [
      cava
    ];

    programs.cava.enable = true;

    xdg.configFile.cava.source = ./settings;
  };
}
