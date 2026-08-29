{
  description = "hp-nixos — bauti dotfiles + home-manager + stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    fast-nix-gc.url = "github:Mic92/fast-nix-gc";
    fast-nix-gc.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    let
      lib = nixpkgs.lib.extend (final: prev: import ./lib { inherit inputs; });
    in
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = { inherit lib; };
    } {
      imports = [
        ./flake
      ];
    };
}
