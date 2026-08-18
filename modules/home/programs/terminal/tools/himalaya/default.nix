{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.home.programs.terminal.tools.himalaya;
in
{
  options.bautinix.home.programs.terminal.tools.himalaya = {
    enable = mkEnableOption "himalaya";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      himalaya
    ];

    xdg.configFile."himalaya".source = ./settings;
  };
}
