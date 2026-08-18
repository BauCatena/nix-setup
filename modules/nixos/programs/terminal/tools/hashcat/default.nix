{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.hashcat;
in
{
  options.bautinix.nixos.programs.terminal.tools.hashcat.enable =
    lib.mkEnableOption "hashcat";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.hashcat ];
  };
}
