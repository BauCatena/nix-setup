{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.services.rtkit;
in
{
  options.bautinix.nixos.services.rtkit = {
    enable = lib.mkEnableOption "rtkit";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
    rtkit
    ];

    security.rtkit = {
      enable = true;
    };
  };
}
