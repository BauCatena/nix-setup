{ config, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.khanelinix) mkBoolOpt;

  cfg = config.bautinix.nixos.services.udisks2;
in
{
  options.bautinix.nixos.services.udisks2 = {
    enable = mkBoolOpt true "enable udisks2 service";
  };

  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
