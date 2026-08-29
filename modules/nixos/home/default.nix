{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) types mkAliasDefinitions;
  inherit (lib.bautinix) mkAfter mkOpt;
  
  dotfiles = "/home/${config.bautinix.user.name}/dotfiles";
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
    environment.pathsToLink = lib.mkAfter [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    bautinix.home.extraOptions = {
      home.file = mkAliasDefinitions options.bautinix.home.file;
      xdg.configFile = mkAliasDefinitions options.bautinix.home.configFile; 
      xdg.enable = lib.mkDefault true;
      home.stateVersion = lib.mkOptionDefault config.system.stateVersion;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
      extraSpecialArgs = {
        inherit inputs dotfiles;
        username = config.bautinix.user.name;
      };
      verbose = true;

      users.${config.bautinix.user.name} = lib.mkMerge [
        config.bautinix.home.extraOptions
        {
          imports = 
            lib.file.importModulesRecursive ../../home
            ++ [ (../../../homes/x86_64-linux + "/bauti@hp-nixos") ];

          home.sessionPath = [
            "/run/wrappers/bin"
            "/run/current-system/sw/bin"
            "${dotfiles}/bin"
          ];

          home.sessionVariables = {
            EDITOR = "nvim";
            VISUAL = "nvim";
          };
        }
      ];
    };
  };
}
