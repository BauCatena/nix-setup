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

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi-flavors = {
      url = "github:yazi-rs/flavors";
      flake = false;
    };

    hyprfm = {
      url = "github:soyeb-jim285/hyprfm";
      flake = false;
    };

    tokyonight = {
      flake = false;
      url = "github:folke/tokyonight.nvim";
    };
  };

   outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        ./flake
      ];
    };
  }
