{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.net-tools;
in
{
  options.bautinix.programs.terminal.tools.net-tools.enable =
    lib.mkEnableOption "net-tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.net-tools ];
  };
}
