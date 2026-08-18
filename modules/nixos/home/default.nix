{
  config,
  lib,
  options,

  ...
}:
let
  inherit (lib) types mkAliasDefinitions;
  inherit (lib.bautinix or lib.bautinix) mkOpt; 
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
    ];

    bautinix.home.extraOptions = {
      home.file = mkAliasDefinitions options.bautinix.home.file;
      home.stateVersion = lib.mkOptionDefault config.system.stateVersion;
      xdg.configFile = mkAliasDefinitions options.bautinix.home.configFile; 
      xdg.enable = lib.mkDefault true;
    };

    home-manager = {
      backupFileExtension = "hm.old";
      useGlobalPkgs = true;
      useUserPackages = true;

      users.${config.bautinix.user.name or config.bautinix.user.name} = mkAliasDefinitions options.bautinix.home.extraOptions;

      verbose = true;
    };
  };
}
