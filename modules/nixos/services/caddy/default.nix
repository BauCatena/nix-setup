{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.services.caddy;
  domain = "homelab.tailb71378.ts.net";
in
{
  options.bautinix.services.caddy = {
    enable = lib.mkEnableOption "caddy";
  };

  config = mkIf cfg.enable {

    services.tailscale.permitCertUid = mkIf config.bautinix.services.tailscale.enable "caddy";

    services.caddy = {
      enable = true;

      virtualHosts."home.${domain}:60001".extraConfig = ''
        reverse_proxy 192.168.122.93:3000
      '';
    };
  };
}
