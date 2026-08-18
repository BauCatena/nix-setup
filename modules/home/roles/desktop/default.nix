{ config, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.bautinix) enabled;

  cfg = config.bautinix.roles.developer;
in
{
  options.bautinix.roles.developer = {
    enable = lib.mkEnableOption "developer role";
  };

  config = mkIf cfg.enable {
    bautinix.suites = {
      development = {
        enable = true;
        aiEnable = true;
        nixEnable = true;
      };
      networking = enabled;
    };
  };
}
