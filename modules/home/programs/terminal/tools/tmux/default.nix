{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.tmux;
in
{
  options.bautinix.programs.terminal.tools.tmux.enable =
    lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];
  };
}
