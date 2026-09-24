{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.archetypes.laptop;
in
{
  options.bautinix.archetypes.laptop = {
    enable = lib.mkEnableOption "the laptop archetype";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      networkmanager
    ];
    bautinix = {
      display-managers.sddm.defaultSession = "niri";
      suites = {
        common.enable = true;
        cibersecurity = {
          enable = true;
          pentest.enable = true;
          network.enable = true;
          wifi.enable = true;
          web.enable = true;

        };
        desktop.enable = true;
      };

    };
  };
}
