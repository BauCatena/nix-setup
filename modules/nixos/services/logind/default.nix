{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.services.logind;
in
{
  options.bautinix.services.logind = {
    enable = mkEnableOption "logind";
  };

  config = mkIf cfg.enable {
    services = {
      logind.settings.Login = {
      KillUserProcesses = true;
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";

      };
    };
  };
}
