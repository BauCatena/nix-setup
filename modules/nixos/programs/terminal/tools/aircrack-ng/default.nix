{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.aircrack-ng;
in
{
  options.bautinix.programs.terminal.tools.aircrack-ng.enable =
    lib.mkEnableOption "aircrack-ng";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.aircrack-ng ];
  };
}
