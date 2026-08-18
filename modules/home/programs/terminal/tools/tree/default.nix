{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.tree;
in
{
  options.bautinix.home.programs.terminal.tools.tree.enable =
    lib.mkEnableOption "tree";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tree ];
  };
}
