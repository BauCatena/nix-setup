{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.hardware.opengl;
in
{
  options.bautinix.nixos.hardware.opengl = {
    enable = lib.mkEnableOption "support for opengl";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
        libva
        libvdpau
        libdrm
      ];
    };

    users.users.bauti.extraGroups = [
      "render"
      "video"
    ];
  };
}
