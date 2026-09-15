{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.bautinix.services.tailscale;
in
{
  options.bautinix.services.tailscale = {
    enable = mkEnableOption "tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale-systray.enable = pkgs.stdenv.hostPlatform.isLinux;
  };
}
