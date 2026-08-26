{
  lib,
  hostname ? null,
  ...
}:
let
  inherit (lib) types;

  mkOpt = (type: default: description: lib.mkOption { inherit type default description; });
 in
{
  options.bautinix.host = {
    name = mkOpt (types.nullOr types.str) hostname "The host name.";
  };
}
