{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.editors.nano;
in
{
  options.bautinix.programs.terminal.editors.nano = {
    enable = mkEnableOption "nano";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nano
    ];

    xdg.configFile."nano".source = ./settings;
  };
}
