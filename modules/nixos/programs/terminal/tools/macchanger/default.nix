{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.macchanger;
in
{
  options.bautinix.programs.terminal.tools.macchanger.enable =
    lib.mkEnableOption "macchanger";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.macchanger ];
  };
}
