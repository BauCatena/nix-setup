{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.roles.desktop;
in
{
  options.bautinix.roles.desktop = {
    enable = lib.mkEnableOption "desktop role";
  };

  config = mkIf cfg.enable {
    bautinix.suites = {
      common = {
      	enable = true;
      };
      desktop = {
        enable = true;
      };
    };
  };
}
