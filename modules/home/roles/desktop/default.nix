{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;
  # NOTE: idk why is it here and how to fix it inherit (lib.bautinix.home) enabled;

  cfg = config.bautinix.home.roles.desktop;
in
{
  options.bautinix.home.roles.desktop = {
    enable = lib.mkEnableOption "desktop role";
  };

  config = mkIf cfg.enable {
    bautinix.home.suites = {
      common = {
	enable = true;
      };
      desktop = {
        enable = true;
      };
    };
  };
}
