{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.virtualisation.podman;
in
{
  options.bautinix.virtualisation.podman = {
    enable = lib.mkEnableOption "podman";

    onBoot = lib.mkEnableOption "onBoot";
  };

  config = mkIf cfg.enable {

    bautinix = {
      linger = true;
      user.extraGroups = [ "docker" "podman" ];
      home.extraOptions = {
        home.shellAliases = {
          "docker-compose" = "podman-compose";
        };
      };

    };

    boot.enableContainers = cfg.onBoot;

    environment.systemPackages = with pkgs; [
      podman-compose
      podman-desktop
    ];

    virtualisation.podman = {
      enable = true;

      dockerCompat= true;
      dockerSocket.enable = true;

      autoPrune = {
        enable = true;
        flags = [ "--all" ];
        dates = "weekly";
      };

      networkSocket = {
        port = 23760;
      };
    };
  };
}
