{
  config,
  lib,
  hostname,

  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.bautinix) mkBoolOpt;

  cfg = config.bautinix.nixos.system.hostname;
in
{
  options.bautinix.nixos.system.hostname = {
    enable = mkBoolOpt true "Whether to configure the system hostname.";
  };

  config = mkIf cfg.enable {
    networking.hostName = hostname;
  };
}
