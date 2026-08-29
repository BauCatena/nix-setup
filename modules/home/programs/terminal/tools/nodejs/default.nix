{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.nodejs;
in
{
  options.bautinix.programs.terminal.tools.nodejs.enable =
    lib.mkEnableOption "nodejs";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nodejs ];
  };
}
