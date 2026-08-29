{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.ripgrep;
in
{
  options.bautinix.programs.terminal.tools.ripgrep.enable =
    lib.mkEnableOption "ripgrep";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];
  };
}
