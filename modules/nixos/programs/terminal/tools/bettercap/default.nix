{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.nixos.programs.terminal.tools.bettercap;
in
{
  options.bautinix.nixos.programs.terminal.tools.bettercap.enable =
    lib.mkEnableOption "bettercap";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bettercap ];
  };
}
