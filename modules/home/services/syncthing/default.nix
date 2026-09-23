{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.bautinix.services.syncthing;
in
{
  options.bautinix.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {

    services.syncthing = {

      enable = true;

      user = "${cfg.bautinix.username}";
      dataDir = "/home/${config.bautinix.username}/.local/share/syncthing";
      configDir = "/home/${config.bautinix.username}/.config/syncthing";

      openDefaultPorts = true;

    };
  };
}
