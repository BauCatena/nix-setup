{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.python3;
in
{
  options.bautinix.home.programs.terminal.tools.python3.enable =
    lib.mkEnableOption "python3";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.python3 ];
  };
}
