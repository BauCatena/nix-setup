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
        desktop.enable = true;
      };

      hardware = {
        audio.enable = true;
        bluetooth.enable = true;
        cpu.amd.enable = true;
        opengl.enable = true;
        power.enable = true;
        storage.enable = true;
        tpm.enable = true;
      };
    };
  };
}
