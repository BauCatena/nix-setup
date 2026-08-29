{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.bettercap;
in
{
  options.bautinix.programs.terminal.tools.bettercap.enable =
    lib.mkEnableOption "bettercap";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bettercap ];
  };
}
