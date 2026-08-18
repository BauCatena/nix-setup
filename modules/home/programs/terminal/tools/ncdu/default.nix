{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.ncdu;
in
{
  options.bautinix.home.programs.terminal.tools.ncdu.enable =
    lib.mkEnableOption "ncdu";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ncdu ];
  };
}
