{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.security.rtkit;
in
{
  options.bautinix.security.rtkit = {
    enable = lib.mkEnableOption "rtkit";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
  };
}
