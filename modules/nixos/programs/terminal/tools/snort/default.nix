{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.snort;
in
{
  options.bautinix.nixos.programs.terminal.tools.snort.enable =
    lib.mkEnableOption "snort";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.snort ];
  };
}
