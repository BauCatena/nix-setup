{
  config,
  lib,
  hostname,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.system.hostname;
in
{
  options.bautinix.system.hostname = {
    enable = mkEnableOption "system hostname";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
