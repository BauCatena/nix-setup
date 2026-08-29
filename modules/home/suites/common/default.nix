{ config, pkgs, lib,  ... }:
let
  inherit (lib) mkIf mkDefault;

  cfg = config.bautinix.suites.common;
in
{
  options.bautinix.suites.common = {
    enable = lib.mkEnableOption "common terminal suite";
  };

  config = mkIf cfg.enable {
    bautinix = {
      programs = {
        terminal = {
          tools = {
            yazi.enable = true;
            btop.enable = true;
            fastfetch.enable = true;
            himalaya.enable = true;
            jq.enable = true;
            ncdu.enable = true;
            ripgrep.enable = true;
            ssh.enable = true;
            tree.enable = true;
            git.enable = true;
            tmux.enable = true;
            nodejs.enable = true;
            python3.enable = true;
            gcc.enable = true;
            atuin.enable = true;
            libsecret.enable = true;
            starship.enable = true;
            bat.enable = true;
            zoxide.enable = true;
          };
          editors = {
              neovim.enable = true;
              nano.enable = true;
          };
          shells = {
            zsh.enable = true;
          };
        };
      };
    };
  };
}
