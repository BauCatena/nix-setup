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

      user = "${config.bautinix.user.name}";
      dataDir = "/home/${config.bautinix.user.name}/.local/share/syncthing";
      # configDir = "/home/${config.bautinix.user.name}/.config/syncthing";

      openDefaultPorts = true;

    };
  };
}
