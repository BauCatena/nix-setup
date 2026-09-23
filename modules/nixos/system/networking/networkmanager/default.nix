{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.system.networking;
in
{
 config = mkIf (cfg.enable && cfg.manager == "networkmanager") {
    bautinix.user.extraGroups = [ "networkmanager" ];

    networking = { 
      networkmanager = {
        enable = true;


        plugins = with pkgs; [
          networkmanager-l2tp
          networkmanager-openvpn
          # networkmanager-sstp # FIXME: - CVE-2026-91838
          # networkmanager-vpnc # FIXME: - CVE-2026-91840 - CVE-2026-91841
        ];
        
        unmanaged = [
        "interface-name:br-*"
        "interface-name:rndis*"
        ];
      };
    };
    systemd.services = {
    
      NetworkManager.reloadIfChanged = true;

      NetworkManager-wait-online.enable = lib.mkForce false;
    };
  };
}
