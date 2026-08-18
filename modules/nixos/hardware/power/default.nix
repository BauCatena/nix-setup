{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.hardware.power;
in
{
  options.bautinix.nixos.hardware.power = {
    enable = lib.mkEnableOption "support for extra power devices";
  };

  config = mkIf cfg.enable {
    services.upower = {
      enable = true;
      percentageAction = 5;
      percentageCritical = 10;
      percentageLow = 25;
    };
  };
}
