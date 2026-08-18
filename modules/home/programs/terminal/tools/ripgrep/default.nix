{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.ripgrep;
in
{
  options.bautinix.home.programs.terminal.tools.ripgrep.enable =
    lib.mkEnableOption "ripgrep";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];
  };
}
