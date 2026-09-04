{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:
let
  wallpaperCfg = config.bautinix.theme.wallpaper;
  wallpaperPath = name: lib.bautinix.theme.wallpaperPath { inherit config pkgs name; };
  wallpaperPaths = names: lib.bautinix.theme.wallpaperPaths { inherit config pkgs names; };
in
{

  # 1. Native Home Manager options (Required)
  home.stateVersion = "26.05";
  home.username = "bauti";
  home.homeDirectory = "/home/bauti";
  home.file.".local/bin" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bin";
    recursive = true;
  };
  # 2. Your custom framework options
  bautinix = {

    user = {
      name = "bauti";
      fullName = "Bautista";
    };

    theme = {
        stylix.enable = true;
        nord.enable = true;
      };

      roles = {
        desktop.enable = true;
      };
  };
}
