{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.starship;
in
{
  options.bautinix.home.programs.terminal.tools.starship.enable =
    lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.starship ];
  };
}
