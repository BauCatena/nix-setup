{ inputs, ... }:
{
  common = import ./common.nix { inherit inputs; };
  mkHome = import ./mk-home.nix { inherit inputs; };
  mkSystem = import ./mk-system.nix { inherit inputs; };
}
