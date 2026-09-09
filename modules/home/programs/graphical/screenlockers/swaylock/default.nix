{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.graphical.screenlockers.swaylock;
in
{
  options.bautinix.programs.graphical.screenlockers.swaylock = {
    enable = mkEnableOption "swaylock";
  };

  config = mkIf cfg.enable {

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
    };

  };
}
