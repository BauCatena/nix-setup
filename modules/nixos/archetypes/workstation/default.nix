{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.archetypes.workstation;
in
{
  options.bautinix.archetypes.workstation = {
    enable = lib.mkEnableOption "the workstation archetype";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      networkmanager
    ];
    bautinix = {
      display-managers.sddm = {
        defaultSession = "plasma";
        autoLogin = true;
      };
      suites = {
        common.enable = true;
        cibersecurity = {
          enable = true;
          wireless.enable = true;
          web.enable = true;
          blue-team.enable = true;
          bruteforce.enable = true;
          social.enable = true;
        };
        desktop.enable = true;
      };
    };
  };
}
