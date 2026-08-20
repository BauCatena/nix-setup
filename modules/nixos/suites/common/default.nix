{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.nixos.suites.common;
in
{
  options.bautinix.nixos.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {

     zramSwap.enable = true;

      hardware.ksm = {
        enable = true;
        sleep = 100; # ms between scans (lower = more aggressive dedup, slightly more CPU)
     };

    environment = {

      # defaultPackages = lib.mkForce [ ];

      systemPackages = with pkgs; [
        coreutils
        curl
        fd
        file
        findutils
        killall
        lsof
        pciutils
        git
        zsh
        neovim
        yazi
        netcat
        util-linux
        rsync
        dnsutils
        btop
        tldr
        unzip
        wget
        xclip
      ];
    };

    bautinix.nixos = {
      hardware = {
        storage.btrfs.enable = true;
      };
      programs = {
        terminal = {
          tools = {
            ssh.enable = mkDefault true;
            bandwhich.enable = true;
          };
        };
      };
      security = {
        gpg.enable = mkDefault true;
        sudo.enable = mkDefault true;
        pam.enable = mkDefault true;
        usbguard.enable = mkDefault true;
      };

      services = {
        openssh.enable = mkDefault true;
        ddccontrol.enable = mkDefault true;
        logind.enable = mkDefault true;
        journald.enable = mkDefault true;
        oomd.enable = mkDefault true;
        earlyoom.enable = mkDefault true;
        logrotate.enable = mkDefault true;
      };

      system = {
        # hostname.enable = mkDefault true; it just does not work.
        fonts.enable = mkDefault true;
      };
    };
  };
}
