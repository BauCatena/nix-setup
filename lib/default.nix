{ inputs, ... }:
{
  file = import ./file {
    inherit inputs;
    self = ../.;
  };
  base64 = import ./base64 { inherit inputs; };
  module = import ./module { inherit inputs; };
  system = import ./system { inherit inputs; };
  theme = import ./theme { inherit inputs; };
}
