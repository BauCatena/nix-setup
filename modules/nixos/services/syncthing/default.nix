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
  syncRoot = "/srv/storage/syncthing";
in
{
  options.bautinix.services.syncthing = {
    enable = mkEnableOption "syncthing";

    isClient = mkEnableOption "whether the device client or server";
  };

  config = mkIf cfg.enable {

    system.activationScripts.setupSyncthingDirs = ''
      mkdir -p ${syncRoot}/{readonly,everything,obsidian}
      chown -R ${username}: ${syncRoot}
    '';

    sops.secrets.syncthing_gui_password = { owner = username; };

    services.syncthing = {
      enable = true;
      user = username;

      dataDir = "${syncRoot}/data";
      configDir = "/home/${username}/.config/syncthing";

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
            name = "lab-nixos";
            id = "VQGDOL3-XUBJQ5T-UPGINWQ-TPUQ53J-2TX2A2K-URCAHAI-2WUQVS4-B5KDFAO";
            addresses = [ "tcp://100.97.207.53:48232" ];
          };
          pc-nixos = {
            name = "pc-nixos";
            id = "TFNVM5W-E4GOZHW-QJQMSDE-2WCZ5CV-JZYEQCW-A3N3QO3-25HSVRU-ZZ5MVQF";
            addresses = [ "tcp://100.113.124.111:48232" ];
            autoAcceptFolders = true;
          };
          # TODO: add phone device
        };

        folders = {
          "read-only" = {
            path = "${syncRoot}/readonly";
            id = "readOnly";
            devices = [ "pc-nixos" "lab-nixos" ];
            type = if cfg.isClient then "receiveonly" else "sendonly";
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
            type = if cfg.isClient then "receiveonly" else "sendonly";
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
