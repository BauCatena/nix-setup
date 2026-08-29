{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.graphical.launchers.tofi;
in
{
  options.bautinix.programs.graphical.launchers.tofi = {
    enable = mkEnableOption "tofi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tofi
    ];

    xdg.configFile."tofi".source = ./settings;
  };
}
