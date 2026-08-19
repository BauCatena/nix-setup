{
  config,
  lib,
  hostname,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.system.hostname;
in
{
  options.bautinix.home.system.hostname = {
    enable = mkEnableOption "system hostname";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
