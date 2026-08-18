{
  lib,
  hostname ? null,

  ...
}:
let
  inherit (lib) types;
  inherit (lib.bautinix) mkOpt;
in
{
  options.bautinix.home.host = {
    name = mkOpt (types.nullOr types.str) hostname "The host name.";
  };
}
