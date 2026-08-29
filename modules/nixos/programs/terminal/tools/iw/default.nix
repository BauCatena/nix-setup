{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.iw;
in
{
  options.bautinix.programs.terminal.tools.iw.enable =
    lib.mkEnableOption "iw";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.iw ];
  };
}
