{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.security.rtkit;
in
{
  options.bautinix.nixos.security.rtkit = {
    enable = lib.mkEnableOption "rtkit";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
  };
}
