{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.emulators.kitty;
in
{
  options.bautinix.programs.terminal.emulators.kitty = {
    enable = mkEnableOption "kitty";
  };

  config = mkIf cfg.enable {
    programs.kitty.enable = true;

    xdg.configFile."kitty".source = ./settings;
  };
}
