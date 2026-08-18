{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.tmux;
in
{
  options.bautinix.home.programs.terminal.tools.tmux.enable =
    lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];
  };
}
