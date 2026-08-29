{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.tools.fastfetch;
in
{
  options.bautinix.programs.terminal.tools.fastfetch = {
    enable = mkEnableOption "fastfetch";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
    ];

    xdg.configFile."fastfetch".source = ./settings;
  };
}
