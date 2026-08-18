{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.services.logind;
in
{
  options.bautinix.nixos.services.logind = {
    enable = mkEnableOption "logind";
  };

  config = mkIf cfg.enable {
    services = {
      logind.settings.Login = {
        KillUserProcesses = true;
      };
    };
  };
}
