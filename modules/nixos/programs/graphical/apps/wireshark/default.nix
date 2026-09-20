{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.wireshark;
in
{
  options.bautinix.programs.graphical.apps.wireshark = {
    enable = mkEnableOption "wireshark";
  };
  config = mkIf cfg.enable {

    # NOTE: Wireshark only works when launching from terminal as sudo
    # sudo wireshark

    bautinix.user.extraGroups = [ "wireshark" ];

    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };
}
