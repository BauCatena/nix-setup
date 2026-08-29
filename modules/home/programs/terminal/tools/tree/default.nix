{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.tree;
in
{
  options.bautinix.programs.terminal.tools.tree.enable =
    lib.mkEnableOption "tree";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tree ];
  };
}
