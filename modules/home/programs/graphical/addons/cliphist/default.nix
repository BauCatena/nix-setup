{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.addons.cliphist; 
in
{
  options.bautinix.programs.graphical.addons.cliphist = {
    enable = mkEnableOption "cliphist";
  };
  config = mkIf cfg.enable {
    # Paquetes globales que instala el módulo
    home.packages = with pkgs; [
      cliphist
    ];
  };

}
