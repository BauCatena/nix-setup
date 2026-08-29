{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf;
  cfg = config.bautinix.programs.graphical.wms.niri;
in
{
  options.bautinix.programs.graphical.wms.niri = {
    enable = lib.mkEnableOption "niri";
  };
  config = mkIf cfg.enable {

   # NOTE move later to themes.
   environment.systemPackages = with pkgs; [
      bibata-cursors
    ];
      programs.niri.enable = true;

    };
}
