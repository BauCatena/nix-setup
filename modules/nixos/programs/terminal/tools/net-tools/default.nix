{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.net-tools;
in
{
  options.bautinix.nixos.programs.terminal.tools.net-tools.enable =
    lib.mkEnableOption "net-tools";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.net-tools ];
  };
}
