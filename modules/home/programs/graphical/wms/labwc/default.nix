{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.bautinix.programs.graphical.wms.labwc;
in
{
  options.bautinix.programs.graphical.wms.labwc = {
    enable = lib.mkEnableOption "labwc";
  };

  config = mkIf cfg.enable {
 
    programs.labwc.enable = true;

  };
}
