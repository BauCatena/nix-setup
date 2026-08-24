{
  description = "hp-nixos — bauti dotfiles + home-manager + stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    fast-nix-gc.url = "github:Mic92/fast-nix-gc";
    fast-nix-gc.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pin to release branch — tracking master pulled inputs incompatible with 26.05
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, stylix, sops-nix, fast-nix-gc, ... }@inputs:
    let

    lib = nixpkgs.lib.extend (final: prev: import ./lib { inherit inputs; });

    in
    {
      nixosConfigurations.hp-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # 2. Tell nixosSystem to use your extended lib
        inherit lib; 

        specialArgs = {
          inherit inputs;
          dotfiles = "/home/bauti/dotfiles";
          hostname = "hp-nixos";
        };

        modules = [
          ./systems/x86_64-linux/hp-nixos/default.nix
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          sops-nix.nixosModules.sops
        ];
      };
    };
  }
