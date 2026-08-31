{ inputs }:
_final: _prev:
let
  base64Lib = import ./base64 { inherit inputs; };
  fileLib = import ./file {
    inherit inputs;
    self = ../.;
  };
  moduleLib = import ./module { inherit inputs; };
  systemLib = import ./system { inherit inputs; };
  themeLib = import ./theme { inherit inputs; };
in
{
  bautinix = moduleLib // {
    theme = themeLib;
  };

  # This line injects default-attrs, force-attrs, etc. into lib.modules
  # so that modules calling inherit (lib.modules) default-attrs; can find them.
  modules = _prev.modules // moduleLib;

  file = fileLib;
  system = systemLib;
  theme = themeLib;
  base64 = base64Lib;

  inherit (fileLib)
    getFile
    getNixFiles
    importFiles
    importDir
    importDirPlain
    importSubdirs
    importModulesRecursive
    customMergeAttrs
    ;

  inherit (moduleLib)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    capitalize
    boolToNum
    packageProfiles
    packageProfileType
    packageProfileRank
    profileIncludes
    mkPackageProfileOption
    resolvePackageProfile
    suitePackageProfile
    suiteProfileIncludes
    default-attrs
    force-attrs
    nested-default-attrs
    nested-force-attrs
    decode
    ;

  inherit (inputs.home-manager.lib) hm;
}
