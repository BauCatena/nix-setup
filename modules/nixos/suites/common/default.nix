{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.common;
in
{
  imports = [
    (lib.getFile "modules/common/suites/common/default.nix")
  ];

  config = mkIf cfg.enable {

    programs.nix-ld = {
      enable = true;
    };

     zramSwap.enable = true;

      hardware.ksm = {
        enable = true;
        sleep = 100; # ms between scans (lower = more aggressive dedup, slightly more CPU)
     };

    bautinix = {
      programs = {
        terminal = {
          tools = {
            ssh.enable = mkDefault true;
            bandwhich.enable = mkDefault true;
            powertop.enable = mkDefault true;
            net-tools.enable = mkDefault true;
            fzf.enable = true;
            gcc.enable = mkDefault true;
            iw.enable = mkDefault true;
          };
        };
      };
      security = {
        gpg.enable = mkDefault true;
        sudo.enable = mkDefault true;
        pam.enable = mkDefault true;
        usbguard.enable = mkDefault true;
        keyring.enable = mkDefault true;
        polkit.enable = mkDefault true;
      };

      services = {
        openssh.enable = mkDefault true;
        ddccontrol.enable = mkDefault true;
        logind.enable = mkDefault true;
        journald.enable = mkDefault true;
        oomd.enable = mkDefault true;
        earlyoom.enable = mkDefault true;
        logrotate.enable = mkDefault true;
        udisks2.enable = mkDefault true;
      };

      system = {
        hostname.enable = true;
        locale.enable = true;
        time.enable = true;
      };
      fonts.enable = mkDefault true;
    };
  };
}
