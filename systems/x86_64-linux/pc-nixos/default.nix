# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:
let
  magicDnsSuffix = "tailb71378.ts.net";
in 
{
  imports =
    [
      ./hardware-configuration.nix
    ];
  services.xserver.videoDrivers = [ "nvidia" ];
  bautinix = {
    nix.enable = true;

    archetypes = {
      workstation.enable = true;
    };
    theme = {
      stylix = {
          enable = true;
          theme = "catppuccin-macchiato";
        };
      catppuccin = {
        enable = true;
      };
    };

    programs.terminal.tools.ssh = {
      enable = true;

    };

    suites = {
        common.enable = true;
        desktop.enable = true;
        cibersecurity.enable = true;
    };

    security = {
        sops = {
          enable = true;
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          defaultSopsFile = lib.getFile "secrets/bauti/default.yaml";
      };
    };

    services = {
      tailscale = {
        enable = true;
      };
    };

    system = {

      boot = {
        enable = true;
        loader = "systemd-boot";
        silentBoot = true;
	# secureBoot = true;
        plymouth = false;
      };

      realtime.enable = true;
      time.enable = true;
      locale.enable = true;

      networking = {
        enable = true;
        optimizeTcp = true;      # BBR congestion control & TCP hardening
        manager = "networkmanager";
      };

      xkb.enable = true;
    };
    hardware = {

    audio.enable = true;
    cpu.amd.enable = true;
    opengl.enable = true;
    gpu.nvidia.enable = lib.mkForce true;
    power.enable = true;
    storage.btrfs.enable = true;
    tpm.enable = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs = {
    zsh.enable = true;

  };

  environment.systemPackages = with pkgs; [
      home-manager
  ];

  system.stateVersion = "26.05";
}

