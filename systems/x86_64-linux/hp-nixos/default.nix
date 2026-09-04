# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  bautinix = {
    nix.enable = true;

    archetypes = {
      laptop.enable = true;
    };
    theme = {
      stylix = {
          enable = true;
          theme = "nord";
        };
      nord = {
        enable = true;
        variant.type = "default";
      };
    };
    suites = {
        common.enable = true;
        desktop.enable = true;
        cibersecurity.enable = true;
      };

    system = {

      boot = {
        enable = true;
        loader = "systemd-boot";
        silentBoot = true;
        plymouth = false;
      };

      realtime.enable = true;
      time.enable = true;
      locale.enable = true;

      networking = {
        enable = true;
        optimizeTcp = true;      # BBR congestion control & TCP hardening
        manager = "networkmanager"; # Or keep NetworkManager if preferred
      };

      xkb.enable = true;
    };
    hardware = {

    audio.enable = true;
    bluetooth.enable = true;
    cpu.amd.enable = true;
    opengl.enable = true;
    gpu.amd.enable = true;
    power.enable = true;
    storage.btrfs.enable = true;
    tpm.enable = true;
    };
  };
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
      home-manager
  ];

  system.stateVersion = "26.05";
}

