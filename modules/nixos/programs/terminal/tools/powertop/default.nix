{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.powertop;
in
{
  options.bautinix.programs.terminal.tools.powertop.enable =
    lib.mkEnableOption "powertop";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.powertop ];
  };
}
