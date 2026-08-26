{ inputs }:
{
  system,
  hostname,
  username,
  modules ? [ ],
  ...
}:
let
  extendedLib = inputs.nixpkgs.lib.extend (final: prev:
    (import ../default.nix { inherit inputs; }) // inputs.home-manager.lib
  );
in
inputs.home-manager.lib.homeManagerConfiguration {
  # 🔓 Explicitly allow unfree packages for standalone home-manager
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  extraSpecialArgs = {
    inherit inputs hostname username system;
    dotfiles = "/home/${username}/dotfiles";
    lib = extendedLib;
  };

  modules = modules;
}
