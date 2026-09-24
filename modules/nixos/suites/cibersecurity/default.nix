{ config, lib, pkgs, inputs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.cibersecurity;
in
{
  options.bautinix.suites.cibersecurity = {
    enable = lib.mkEnableOption "cibersecurity configuration";

    wireless.enable = lib.mkEnableOption "wireless toolkit";
    social.enable = lib.mkEnableOption "social toolkit";
    web.enable = lib.mkEnableOption "web toolkit";
    threat-intelligence.enable = lib.mkEnableOption "defensive toolkit";
    bruteforce.enable = lib.mkEnableOption "bruteforce decoding toolkit";
  };

  config = mkIf cfg.enable {

    bautinix.programs.graphical.apps.qemu.enable = true;

    environment.systemPackages = with pkgs; [
      crunch
    ] ++ lib.optionals cfg.pentest.enable [
        metasploit
      ] ++ lib.optionals cfg.network.enable [
        bettercap
        nmap
        tcpdump
        macchanger
        wireshark
      ] ++ lib.optionals cfg.wifi.enable  [
        aircrack-ng
        airgeddon
      ] ++ lib.optionals cfg.bruteforce.enable [
        hashcat
      ] ++ lib.optionals cfg.social.enable [
        social-engineer-toolkit
        maltego
      ] ++ lib.optionals cfg.threat-intelligence.enable [
        snort
        dnstwist
      ] ++ lib.optionals cfg.web.enable [
        burpsuite
        gobuster
      ];
  };
}
