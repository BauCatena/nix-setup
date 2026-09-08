{ config, lib, pkgs, hostname, ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.common;
in
{
  options.bautinix.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };


  config = mkIf cfg.enable {

    environment = {
       defaultPackages = lib.mkForce [ ];

      systemPackages = with pkgs; [
        coreutils
        curl
        fd
        file
        findutils
        killall
        lsof
        pciutils
        git
        zsh
        neovim
        netcat
        util-linux
        rsync
        dnsutils
        btop
        tldr
    	  tree
        nix-ld
        unzip
        wget
        xclip
      ];
    };
    programs.nix-ld.enable = true;
  };
}
