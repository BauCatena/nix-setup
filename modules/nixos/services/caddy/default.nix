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

      virtualHosts."home.${domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:3000
      '';
    };
  };
}
