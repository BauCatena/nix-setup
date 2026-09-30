{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.bautinix.services.syncthing;
  username = config.bautinix.user.name;
  syncRoot = "/srv/syncthing";
in
{
  options.bautinix.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {

    system.activationScripts.setupSyncthingDirs = ''
      mkdir -p ${syncRoot}/{data,root,readonly,everything,obsidian}
      chown -R ${username}: ${syncRoot}
    '';

    sops.secrets.syncthing_gui_password = { owner = username; };

    services.syncthing = {
      enable = true;
      user = username;

      dataDir = "${syncRoot}/data";
      configDir = "/home/${username}/.config/syncthing";
      guiAddress = "127.0.0.1:8384";

      guiPasswordFile = config.sops.secrets.syncthing_gui_password.path;

      settings = {
        options = {
          listenAddresses = [
            "tcp://0.0.0.0:48232"
            "quic://0.0.0.0:48232"
          ];
        };

        devices = {
          lab-nixos = {
            id = "7S6HATB-QZHADNN-WNRL65U-PASUOO3-DA6OJ3E-RQ4OI7W-DN3OEDP-BOKSQA4";
            addresses = [ "tcp://100.97.207.53:48232" ];
          };
          pc-nixos = {
            id = "D4JLFS2-VW2FKLH-MFTYFQ2-VE5TYRH-T5XOGCP-W6WECZN-MU7WBHL-QI2QTQA";
            addresses = [ "tcp://100.113.124.111:48232" ];
          };
          # NOTE: add phone device
        };

        folders = {
          "root" = {
            path = "${syncRoot}/root";
            id = "root";
            devices = [ "pc-nixos" "lab-nixos" ];
          };
          "read-only" = {
            path = "${syncRoot}/readonly";
            id = "readOnly";
            devices = [ "pc-nixos" "lab-nixos" ];
            type = "receiveonly";
          };
          "everything" = {
            path = "${syncRoot}/everything";
            id = "everything";
            devices = [ "pc-nixos" "lab-nixos" ];
          };
          "obsidian" = {
            path = "${syncRoot}/obsidian";
            id = "obsidian-vault";
            devices = [ "pc-nixos" "lab-nixos" ];
            versioning = {
              type = "staggered";
              params = {
                cleanInterval = "3600";
                maxAge = "31536000";
              };
            };
          };
        };
      };
    };

    networking.firewall = mkIf config.bautinix.services.tailscale.enable {
      interfaces."tailscale0".allowedTCPPorts = [ 48232 8384 ];
      interfaces."tailscale0".allowedUDPPorts = [ 48232 ];
    };

  };
}
