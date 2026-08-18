{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.jq;
in
{
  options.bautinix.home.programs.terminal.tools.jq.enable =
    lib.mkEnableOption "jq JSON processor";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.jq ];
  };
}
