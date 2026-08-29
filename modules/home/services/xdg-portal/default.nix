{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.services.xdg-portals;
in
{
  options.bautinix.services.xdg-portals = {
    enable = mkEnableOption "xdg compatibility portals";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      # NOTE default config to avoid warning
      config = {
        niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          "org.freedesktop.impl.portal.Screenshot" = "gnome";
        };
      };
    };
  };
}
