{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.common;
in
{
  options.bautinix.suites.common = {
    enable = lib.mkEnableOption "common headless configuration";
  };

  config = mkIf cfg.enable {
    home = {
      # Silence login messages in shells
      file = {
        ".hushlogin".text = "";
      };

      sessionVariables = {
        LESSHISTFILE = "${config.xdg.cacheHome}/less.history";
        WGETRC = "${config.xdg.configHome}/wgetrc";
      };

      shellAliases = {
        nixcfg = "nvim ${config.home.homeDirectory}/dotfiles/nixosConfig/flake.nix";
      };
    };

    # Enable your decentralized modular options here!
    # Turning on the suite automatically flips these switches on:
    bautinix = {
      programs = {
        terminal = {
          tools = {
            yazi.enable = mkDefault true;
            fastfetch.enable = mkDefault true;
            btop.enable = mkDefault true;
            tree.enable = mkDefault true;
            ncdu.enable = mkDefault true;
            ripgrep.enable = mkDefault true;
            jq.enable = mkDefault true;
            ssh.enable = mkDefault true;
          };
          editors = {
            neovim.enable = mkDefault true;
            nano.enable = mkDefault true;
          };
        };
      };
    };

    xdg.configFile.wgetrc.text = "";
  };
}
