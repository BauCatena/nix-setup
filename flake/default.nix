{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in
{
  imports = [
    ../lib
    ./home.nix
    ./config.nix
    ./packages.nix
    ./overlays.nix
    ./docs.nix
    inputs.flake-parts.flakeModules.partitions
  ];

  partitions.dev = {
    module = ./dev;
    extraInputsFlake = ./dev;
  };

  partitionedAttrs = lib.genAttrs [
    "checks"
    "devShells"
    "formatter"
    "templates"
  ] (_: "dev");
}
