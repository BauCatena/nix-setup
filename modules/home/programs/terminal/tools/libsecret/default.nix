{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.home.programs.terminal.tools.libsecret;
in
{
  options.bautinix.home.programs.terminal.tools.libsecret.enable =
    lib.mkEnableOption "libsecret";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libsecret ];
  };
}
