{ config, lib, pkgs, inputs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.cibersecurity;
in
{
  options.bautinix.suites.cibersecurity = {
    enable = lib.mkEnableOption "cibersecurity configuration";
  };

  config = mkIf cfg.enable {

    bautinix = {
        programs = {
          terminal = {
            tools = {
              aircrack-ng = mkIf config.bautinix.hardware.bluetooth.enable {
                enable = true;
              };
              bettercap.enable = true;
              hashcat.enable = true;
              metasploit.enable = true;
              nmap.enable = true;
              snort.enable = true;
              tcpdump.enable = true;
              macchanger.enable = true;
            };
          };
          graphical = mkIf config.bautinix.suites.desktop.enable {
            apps = {
              wireshark.enable = true;
              burpsuite.enable = true;
            };
          };
        };
    };
  };
}
