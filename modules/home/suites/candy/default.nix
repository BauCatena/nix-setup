{ config, pkgs, lib,  ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.candy;
in
{
  options.bautinix.suites.candy = {
    enable = lib.mkEnableOption "candy suite";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lavat
      cmatrix
      asciiquarium
      pipes
      peaclock
      sl
    ];
  };
}


