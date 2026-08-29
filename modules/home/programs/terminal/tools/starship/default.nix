{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.starship;
in
{
  options.bautinix.programs.terminal.tools.starship.enable =
    lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;       
    };
  };
}
