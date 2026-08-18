{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.tcpdump;
in
{
  options.bautinix.nixos.programs.terminal.tools.tcpdump.enable =
    lib.mkEnableOption "tcpdump";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.tcpdump ];
  };
}
