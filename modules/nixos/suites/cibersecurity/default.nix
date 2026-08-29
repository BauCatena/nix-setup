{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.cibersecurity;
in
{
  options.bautinix.suites.cibersecurity = {
    enable = lib.mkEnableOption "cibersecurity configuration";
  };

  config = mkIf cfg.enable {

  bautinix.suites.desktop.enable = true;

    bautinix = {
        programs = {
          terminal = {
            tools = {
              aircrack-ng.enable = true;  # NOTE add a if bluetooth or wireless is enable, also enable this to avoid unnecesary pc pkgs.
              bettercap.enable = true;
              hashcat.enable = true;
              metasploit.enable = true;
              nmap.enable = true;
              snort.enable = true;
              tcpdump.enable = true;
            };
          };
          graphical = { # Enable when desktop = true
            apps = {
              wireshark.enable = true;
              burpsuite.enable = true;
            };
          };
        };
    };
  };
}
