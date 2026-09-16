{ inputs }:
{
  system,
  hostname,
  username ? "bauti",
  matchingHomes ? null,
  nixosModules ? null,
  modules ? [ ],
  overlays ? [ ],
  ...
}:
let
  extendedLib = inputs.nixpkgs.lib.extend (import ../overlay.nix { inherit inputs; });

  # The helper functions (mkHomeManagerConfig, mkHomeConfigs, etc.) live here
  common = import ./common.nix { inherit inputs; };

  baseSystemModules =
    if nixosModules == null then
      extendedLib.file.importModulesRecursive ../../modules/nixos
    else
      nixosModules;

  resolvedMatchingHomes =
    if matchingHomes == null then
      common.mkHomeConfigs { inherit system hostname; flake = inputs.self; }
    else
      matchingHomes;

  homeManagerConfig = common.mkHomeManagerConfig {
    inherit extendedLib inputs system hostname;
    matchingHomes = resolvedMatchingHomes;
    inputPackageSets = { };
    isNixOS = true;
  };
in
extendedLib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs hostname username;
    lib = extendedLib;
    dotfiles = "/home/${username}/dotfiles";
  };
  modules = [
    { nixpkgs = { inherit system overlays; }; }
    inputs.home-manager.nixosModules.home-manager
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.fast-nix-gc.nixosModules.default
    inputs.stylix.nixosModules.stylix

    homeManagerConfig
  ]
  ++ baseSystemModules
  ++ [ ../../systems/${system}/${hostname} ]
  ++ modules;
}
