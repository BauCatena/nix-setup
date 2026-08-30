{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.system.networking;
in
{
  config = mkIf (cfg.enable && cfg.manager == "connman") {
    services.connman = {
      enable = true;

      networkInterfaceBlacklist = [
        "vmnet"
        "vboxnet"
        "virbr"
        "ifb"
        "ve"
      ];
    };
  };
}
