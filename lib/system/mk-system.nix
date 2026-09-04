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
  baseSystemModules =
    if nixosModules == null then
      extendedLib.file.importModulesRecursive ../../modules/nixos
    else
      nixosModules;
in
extendedLib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs hostname username;
    lib = extendedLib;
    dotfiles = "/home/${username}/dotfiles";
  };
  modules = [
    {
      nixpkgs = {
        inherit system overlays;
      };
    }
    inputs.home-manager.nixosModules.home-manager
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.fast-nix-gc.nixosModules.default
    inputs.stylix.nixosModules.stylix
  ]
  ++ baseSystemModules
  ++ [ ../../systems/${system}/${hostname} ]
  ++ modules;
}
