{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:
{
  imports = [
  ] ++ lib.file.importModulesRecursive ../../../modules/home;

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
      roles = {
        desktop.enable = true;
      };
  };
}
