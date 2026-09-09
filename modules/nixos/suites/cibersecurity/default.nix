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
    blue-team.enable = lib.mkEnableOption "defensive toolkit";
    bruteforce.enable = lib.mkEnableOption "bruteforce decoding toolkit";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      metasploit
      crunch
    ] ++ lib.optionals cfg.wireless.enable [
        bettercap
        nmap
        tcpdump
        macchanger
        wireshark
      ] ++ lib.optionals (cfg.wireless.enable && config.bautinix.hardware.bluetooth.enable) [
        aircrack-ng
        airgeddon
      ] ++ lib.optionals cfg.bruteforce.enable [
        hashcat
      ] ++ lib.optionals cfg.social.enable [
        social-engineer-toolkit
        maltego
      ] ++ lib.optionals cfg.blue-team.enable [
        snort
      ] ++ lib.optionals cfg.web.enable [
        burpsuite
        gobuster
      ];
  };
}
