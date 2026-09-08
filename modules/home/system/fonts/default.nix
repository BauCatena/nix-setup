{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.home.fonts;

in
{
  imports = [
    (lib.getFile "modules/common/fonts/default.nix")
  ];

  options.bautinix.home.fonts = with types; {
    enable = lib.mkEnableOption "home-manager font settings";

    default = mkOpt str config.bautinix.fonts.mono "Default UI font family name";
    size = mkOpt int 12 "Default font size";

    # Canonical Monaspace font names live under `bautinix.fonts.monaspace`.
    # Consumers should read from that namespace directly.

  };

  config = mkIf cfg.enable {
    # Intentionally empty; consumer modules reference the options.
  };
}
