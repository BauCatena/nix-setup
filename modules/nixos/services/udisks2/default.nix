{ config, lib, ... }:

with lib;

let

  cfg = config.bautinix.services.udisks2;
in
{
  options.bautinix.services.udisks2 = {
    enable = mkEnableOption "enable udisks2 service";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
