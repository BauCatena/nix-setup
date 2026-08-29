{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.nmap;
in
{
  options.bautinix.programs.terminal.tools.nmap.enable =
    lib.mkEnableOption "nmap";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nmap ];
  };
}
