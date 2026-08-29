{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.fzf;
in
{
  options.bautinix.programs.terminal.tools.fzf.enable =
    lib.mkEnableOption "fzf";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fzf ];
  };
}
