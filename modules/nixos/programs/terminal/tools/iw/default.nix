{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.iw;
in
{
  options.bautinix.nixos.programs.terminal.tools.iw.enable =
    lib.mkEnableOption "iw";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.iw ];
  };
}
