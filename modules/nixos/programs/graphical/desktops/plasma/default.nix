{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.programs.graphical.desktops.plasma;
in
{
  options.bautinix.programs.graphical.desktops.plasma = {
    enable = lib.mkEnableOption "using KDE Plasma as the desktop environment";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        wl-clipboard
      ];

      plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        khelpcenter
      ];
    };

    bautinix = {
      display-managers.sddm = {
        inherit (cfg) enable;
      };

      system.xkb.enable = true;
    };

    services.desktopManager.plasma6.enable = true;
  };
}
