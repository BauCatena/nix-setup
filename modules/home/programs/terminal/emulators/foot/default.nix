{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.home.programs.terminal.emulators.foot;
in
{
  options.bautinix.home.programs.terminal.emulators.foot = {
    enable = mkEnableOption "foot";
  };

  config = mkIf cfg.enable {
    programs.foot.enable = true;

    xdg.configFile."foot".source = ./settings;
  };
}
