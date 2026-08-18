{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.bautinix.home.programs.graphical.wms.niri;
in
{
  options.bautinix.home.programs.graphical.wms.niri = {
    enable = lib.mkEnableOption "niri";
  };

  config = mkIf cfg.enable {

    xdg.configFile."niri".source = ./settings;
  };
}
