{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.nmap;
in
{
  options.bautinix.nixos.programs.terminal.tools.nmap.enable =
    lib.mkEnableOption "nmap";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nmap ];
  };
}
