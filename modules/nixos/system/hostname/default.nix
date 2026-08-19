{
  config,
  lib,
  hostname,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.nixos.system.hostname;
in
{
  options.bautinix.nixos.system.hostname = {
    enable = mkEnableOption "system hostname";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
