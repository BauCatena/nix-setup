{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.terminal.emulators.foot;
in
{
  options.bautinix.programs.terminal.emulators.foot = {
    enable = mkEnableOption "foot";
  };

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
    
      settings = {
        main = {

          term = "xterm-256color";
          pad = "1x1 center";
          font = "${config.bautinix.fonts.stacks.terminal}:size=12";

          };
        colors-light = {

          background = lib.mkForce "191919";

        };
        colors-dark = {

          background = lib.mkForce "191919";

        };
      };
    };
  };
}
