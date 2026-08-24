{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.archetypes.laptop;
in
{
  options.bautinix.nixos.archetypes.laptop = {
    enable = lib.mkEnableOption "the laptop archetype";
  };

  config = mkIf cfg.enable {
    bautinix.nixos = {
      suites = {
        common.enable = true;
        cibersecurity.enable = true;
      };
    programs.graphical.wms.niri.enable = true;
    };
  };
}
