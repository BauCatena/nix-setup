{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.editors.neovim;
in
{
  options.bautinix.programs.terminal.editors.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
      pkgs.pyright            # Provides `pyright-langserver`
      pkgs.lua-language-server # Provides `lua-language-server`
    ];

    xdg.configFile."nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "/home/bauti/dotfiles/modules/home/programs/terminal/editors/neovim/settings";
      recursive = true;
    };
  };
}
