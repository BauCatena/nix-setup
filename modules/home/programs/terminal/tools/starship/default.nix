{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.starship;

  theme = lib.toLower (config.bautinix.theme.wallpaper.theme);

  palette = import ../../../../theme/${theme}/colors.nix;
  schemas = import ./schemas/modules.nix { inherit palette; };
in
{
  options.bautinix.programs.terminal.tools.starship.enable =
    lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = lib.mkDefault schemas.default;
    };
  };
}
