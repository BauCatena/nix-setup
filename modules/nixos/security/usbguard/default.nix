{
  config,
  lib,

  ...
}:
let
  cfg = config.bautinix.nixos.security.usbguard;
in
{
  options.bautinix.nixos.security.usbguard = {
    enable = lib.mkEnableOption "default usbguard configuration";
  };

  config = lib.mkIf cfg.enable {
    services.usbguard = {
      IPCAllowedUsers = [
        "root"
        "${config.bautinix.nixos.user.name}"
      ];
      presentDevicePolicy = "allow";
      rules = ''
        allow with-interface equals { 08:*:* }

        # Reject devices with suspicious combination of interfaces
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }
      '';
    };
  };
}
