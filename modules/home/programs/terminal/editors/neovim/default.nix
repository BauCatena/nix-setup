{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.home.programs.terminal.editors.neovim;
in
{
  options.bautinix.home.programs.terminal.editors.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      pkgs.pyright            # Provides `pyright-langserver`
      pkgs.lua-language-server # Provides `lua-language-server`
    ];

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/nixosConfig/modules/home/programs/terminal/editors/neovim/settings";
    };
  };
}
