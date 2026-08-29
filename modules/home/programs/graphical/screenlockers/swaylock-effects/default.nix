{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.graphical.screenlockers.swaylock-effects;
in
{
  options.bautinix.programs.graphical.screenlockers.swaylock-effects = {
    enable = mkEnableOption "swaylock-effects";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      swaylock-effects
    ];

    xdg.configFile."swaylock-effects".source = ./settings;
  };
}
