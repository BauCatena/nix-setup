{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.default;
in {
  options.services.default = {
    enable = mkEnableOption "Enable default system (Must): Firefox, zsh";
  };

  config = mkIf cfg.enable {

    services.logind = {
      lidSwitch = "suspend";        # o "lock"
      lidSwitchExternalPower = "suspend";
      # lockOnResume = true;       # en algunas versiones
    };
  };
}
