{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.bautinix.services.syncthing;
  username = config.bautinix.user.name;

in
{
  options.bautinix.services.syncthing = {
    enable = mkEnableOption "syncthing";
  };

  config = mkIf cfg.enable {

    services.syncthing = {

      enable = true;

      user = "${username}";

      devices = {
        lab-nixos = {
          adresses = [ "tcp://100.97.207.53:51820" ];
          id = "7S6HATB-QZHADNN-WNRL65U-PASUOO3-DA6OJ3E-RQ4OI7W-DN3OEDP-BOKSQA4";
        };
        pc-nixos = {
          adresses = [ "tcp://100.113.124.111:51820" ];
          id = "D4JLFS2-VW2FKLH-MFTYFQ2-VE5TYRH-T5XOGCP-W6WECZN-MU7WBHL-QI2QTQA";
        };
      };

      folders = {
        "/home/${username}/syncthing" = {
        id = "root";
        devices = [ "pc-nixos" "lab-nixos"];
 
        };
      };

      dataDir = "/home/${username}/syncthing";
      configDir = "/home/${username}/.config/syncthing";

      openDefaultPorts = true;
      guiAddress = "127.0.0.1:8384" ;
    };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  };
}
