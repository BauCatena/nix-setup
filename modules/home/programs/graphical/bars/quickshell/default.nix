{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.graphical.bars.quickshell;
in
{
  options.bautinix.programs.graphical.bars.quickshell = {
    enable = mkEnableOption "quickshell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
    ];

    programs.quickshell.enable = true;

    xdg.configFile."quickshell".source = ./settings;
  };
}
