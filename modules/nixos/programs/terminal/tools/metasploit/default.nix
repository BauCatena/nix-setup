{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.metasploit;
in
{
  options.bautinix.programs.terminal.tools.metasploit.enable =
    lib.mkEnableOption "metasploit";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.metasploit ];
  };
}
