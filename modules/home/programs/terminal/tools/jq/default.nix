{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.jq;
in
{
  options.bautinix.programs.terminal.tools.jq.enable =
    lib.mkEnableOption "jq JSON processor";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.jq ];
  };
}
