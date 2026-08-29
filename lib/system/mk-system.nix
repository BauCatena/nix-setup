{ inputs }:
{
  system,
  hostname,
  username ? "bauti",
  matchingHomes ? null,
  nixosModules ? null,
  modules ? [ ],
  ...
}:
let
  # Extend nixpkgs.lib using your project's overlay so custom helpers are globally available
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
    # Configure nixpkgs system target
    {
      nixpkgs = {
        inherit system;
      };
    }

    # Third-party plugin modules from your flake inputs
    inputs.home-manager.nixosModules.home-manager
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.sops-nix.nixosModules.sops
    inputs.fast-nix-gc.nixosModules.default
    inputs.stylix.nixosModules.stylix

    # Recursively import all shared modules inside modules/nixos
  ]
  ++ baseSystemModules
  # Host-specific entry point configuration
  ++ [
    ../../systems/${system}/${hostname}
  ]
  # Additional ad-hoc modules passed down
  ++ modules;
}
