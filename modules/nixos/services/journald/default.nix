{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.services.journald;
in
{
  options.bautinix.nixos.services.journald = {
    enable = mkEnableOption "journald storage limits";
  };

  config = mkIf cfg.enable {

    services.journald.extraConfig = ''
      SystemMaxUse=1G
      SystemKeepFree=2G
      MaxRetentionSec=1month
    '';
  };
}
