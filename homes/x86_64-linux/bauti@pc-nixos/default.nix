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
    programs = {
      graphical = {
        browsers = {
          firefox = {
            extensions.installMethod = "policy";
            gpuAcceleration = true;
            hardwareDecoding = true;
            settings = {
              "media.av1.enabled" = false;
              "media.hardwaremediakeys.enabled" = true;
            };
          };
        };
      };
    };

    services = {
      sops = {
        enable = true;
        defaultSopsFile = lib.getFile "secrets/bautinix/bauti/default.yaml";
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      };
    };

    user = {
      name = "bauti";
      fullName = "Bautista";
    };

    theme = {
        stylix = {
          enable = true;
        # theme = "catppuccin-macchiato";
        };
        catppuccin = {
          enable = true;
        };
      };

      roles = {
        desktop.enable = true;
      };
    suites = {
      candy.enable = true;
      workstation.enable = true;
    };
  };
}
