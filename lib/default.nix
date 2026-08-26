{ inputs, ... }:
let
  lib = inputs.nixpkgs.lib;
in
{
  file = import ./file {
    inherit inputs;
    self = ../.;
  };
  system = import ./system { inherit inputs; };

  bautinix = {
    mkOpt = type: default: description:
      lib.mkOption { inherit type default description; };
    
    enabled = {
      enable = true;
    };
    
    disabled = {
      enable = false;
    };
  };
}
