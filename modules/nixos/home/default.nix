{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) types mkAliasDefinitions;

  # Helper for defining options cleanly
  mkOpt = type: default: description:
    lib.mkOption { inherit type default description; };

  # Dynamically get the dotfiles path based on the modular user name
  dotfiles = "/home/${config.bautinix.user.name}/dotfiles";

  # Custom backup script from your original home.nix
  hmBackupScript = pkgs.writeShellScript "hm-backup" ''
    set -eu
    path="$1"
    ext="''${HOME_MANAGER_BACKUP_EXT:-hm-bak}"
    for old in "$path.$ext"*; do
      if [ -e "$old" ]; then
        rm -f "$old"
      fi
    done
    mv "$path" "$path.$ext"
  '';
in
{
  options.bautinix.home = with types; {
    configFile =
      mkOpt attrs { }
        "A set of files to be managed by home-manager's <option>xdg.configFile</option>.";
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
    file = mkOpt attrs { } "A set of files to be managed by home-manager's <option>home.file</option>.";
  };

  config = {

    # NixOS system-level config
    environment.pathsToLink = lib.mkAfter [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    # Map our custom bautinix options to standard Home Manager options
    bautinix.home.extraOptions = {
      home.file = mkAliasDefinitions options.bautinix.home.file;
      xdg.configFile = mkAliasDefinitions options.bautinix.home.configFile; 
      xdg.enable = lib.mkDefault true;
      home.stateVersion = lib.mkOptionDefault config.system.stateVersion;
    };

    # The main Home Manager setup
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      extraSpecialArgs = { inherit dotfiles; };
      verbose = true;

      # Define the user-specific Home Manager environment dynamically
      users.${config.bautinix.user.name} = { config, ... }: {
        
        # Bring in your modular imports and our custom aliases
        imports = [

          (mkAliasDefinitions options.bautinix.home.extraOptions)
          ]
          ++ lib.file.importModulesRecursive ../../home;

        home.sessionPath = [
          "/run/wrappers/bin"
          "/run/current-system/sw/bin"
          "${dotfiles}/bin"
        ];

        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        # Out-of-store symlinks
        home.file.".local/bin" = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bin";
          recursive = true;
        };

        # Global cursor configuration
        home.pointerCursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 22;
          gtk.enable = true;
          x11.enable = true;
        };
      };
    };
  };
}
