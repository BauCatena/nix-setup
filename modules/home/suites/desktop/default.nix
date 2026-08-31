{ config, pkgs, lib,  ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.desktop;
in
{
  options.bautinix.suites.desktop = {
    enable = lib.mkEnableOption "desktop terminal suite";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ drawio ];

    bautinix = {
      programs = {
        terminal = {
          tools = {
            cava.enable = true;
            cmatrix.enable = true;
          };
          emulators = {
            foot.enable = true;
          };
        };
        graphical = {
          addons = {
            libinput-gestures.enable = true;
            grim.enable = true;
            slurp.enable = true;
            wl-clipboard.enable = true;
            cliphist.enable = true;
            playerctl.enable = true;
            libnotify.enable = true;
            xwayland-satellite.enable = true;
          };
          apps = {
            libreoffice.enable = true;
            obsidian.enable = true;
            vesktop.enable = true;
            spotify.enable = true;
          };
          bars = { quickshell.enable = true; };
          browsers = { firefox.enable = true; };
          launchers = { tofi.enable = true; };
          screenlockers = { swaylock-effects.enable = true; };
          wms = { niri.enable = true; };
        };
      };
      services = {
        awww.enable = false;
      };
      system = { xdg.enable = true; };
    };
  };
}


