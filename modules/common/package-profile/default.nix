{
  lib,
  ...
}:
let
  inherit (lib.bautinix) mkOpt packageProfileType;
in
{
  options.bautinix.packageProfile =
    mkOpt packageProfileType "maximal"
      "Package payload profile to use when suite-specific profiles are not set.";
}
