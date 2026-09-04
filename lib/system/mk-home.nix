{ inputs }:
{
  system,
  hostname,
  username,
  extraInputPatches ? { },
  modules ? [ ],
  ...
}:
let
  inherit (inputs.nixpkgs.lib) hasSuffix;

  patchesRoot = ../../patches; # adjust if your patches live elsewhere

  mkInputPatches =
    inputName:
    let
      patchDir = patchesRoot + "/${inputName}";
    in
    if builtins.pathExists patchDir then
      map (patchName: patchDir + "/${patchName}") (
        builtins.filter (patchName: hasSuffix ".patch" patchName) (
          builtins.attrNames (builtins.readDir patchDir)
        )
      )
    else
      [ ];

  normalizeExtraInputPatches =
    pkgs: patches:
    let
      patchList = if builtins.isFunction patches then patches pkgs else patches;
      mkPatch =
        patch:
        if builtins.isAttrs patch && patch ? url then
          let
            fetcher = patch.fetcher or "fetchpatch2";
            fetchPatch = if builtins.isString fetcher then pkgs.${fetcher} else fetcher;
          in
          fetchPatch (removeAttrs patch [ "fetcher" ])
        else
          patch;
    in
    map mkPatch patchList;

  mkInputPatchList =
    pkgs: inputName:
    let
      patchFile = patchesRoot + "/${inputName}/default.nix";
      filePatches =
        if builtins.pathExists patchFile then
          import patchFile { inherit pkgs; inherit (pkgs) lib; }
        else
          [ ];
      configuredPatches = extraInputPatches.${inputName} or [ ];
    in
    mkInputPatches inputName
    ++ normalizeExtraInputPatches pkgs filePatches
    ++ normalizeExtraInputPatches pkgs configuredPatches;

  mkPatchedFlake =
    pkgs: inputName: input: flakeInputs:
    let
      patches = mkInputPatchList pkgs inputName;
      patchedSrc =
        if patches == [ ] then
          input
        else
          pkgs.applyPatches {
            name = "${inputName}-patched";
            src = input;
            inherit patches;
          };
    in
    if patches == [ ] then
      input
    else
      {
        outPath = "${patchedSrc}";
        rev = input.rev or null;
        shortRev = input.shortRev or "patched";
      }
      // (import "${patchedSrc}/flake.nix").outputs (
        flakeInputs // { self = null; }
      );

  bootstrapPkgs = inputs.nixpkgs.legacyPackages.${system};

  nixpkgs = mkPatchedFlake bootstrapPkgs "nixpkgs" inputs.nixpkgs { };

  home-manager = mkPatchedFlake bootstrapPkgs "home-manager" inputs.home-manager {
    inherit nixpkgs;
  };

  extendedLib = inputs.nixpkgs.lib.extend (
    final: prev:
    {
      bautinix = import ../module { inherit inputs; };
    }
    // home-manager.lib
  );
 # -- Recursively collect .nix files under a directory, as a flat list of paths.
  # Home Manager imports paths itself, so we don't need to `import` them here.
  collectModules =
  dir:
  let
    walk =
      path:
      let
        entries = builtins.readDir path;
      in
      builtins.concatMap (
        name:
        let
          entryType = entries.${name};
          full = path + "/${name}";
        in
        if entryType == "directory" then
          walk full
        else if entryType == "regular" && name == "default.nix" then
          [ full ]
        else
          [ ]
      ) (builtins.attrNames entries);
  in
  if builtins.pathExists dir then walk dir else [ ];

  hmSharedModules = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.sops-nix.homeManagerModules.sops
  ]
  ++ collectModules ../../modules/home;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  extraSpecialArgs = {
    inherit inputs hostname username system;
    dotfiles = "/home/${username}/dotfiles";
    lib = extendedLib;
  };
  modules = hmSharedModules ++ modules;
}
