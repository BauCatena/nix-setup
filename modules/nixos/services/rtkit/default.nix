{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.services.rtkit;
in
{
  options.bautinix.services.rtkit = {
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
