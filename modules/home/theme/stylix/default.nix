{
  config,
  lib,
  pkgs,
  options,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    types
    ;
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.theme.stylix;
  fontCfg = config.bautinix.fonts;
  themeCfg = config.bautinix.theme;

  themeApps = {
    catppuccin = [
      "bat"
      "btop"
      "cava"
      "fish"
      "foot"
      "fzf"
      "ghostty"
      "kitty"
      "lazygit"
      "ncspot"
      "neovim"
      "opencode"
      "tmux"
      "vesktop"
      "zathura"
      "zellij"
      "qt"
    ];
    nord = [
      "ghostty"
      "helix"
      "kitty"
      "neovim"
      "superfile"
      "tmux"
      "yazi"
    ];
    tokyonight = [
      "alacritty"
      "bat"
      "btop"
      "cava"
      "fish"
      "foot"
      "fzf"
      "kitty"
      "lazygit"
      "neovim"
      "tmux"
      "vesktop"
      "yazi"
      "qt"
    ];
  };

  isThemedBy =
    app:
    lib.any (theme: themeCfg.${theme}.enable && lib.elem app themeApps.${theme}) [
      "catppuccin"
      "nord"
      "tokyonight"
    ];

  anyCuratedTheme = themeCfg.catppuccin.enable || themeCfg.nord.enable || themeCfg.tokyonight.enable;
in
{
  options.bautinix.theme.stylix = {
    enable = mkEnableOption "stylix theme for applications";
    theme = mkOpt types.str "catppuccin-macchiato" "base16 theme file name";

    cursor = {
      name = mkOpt types.str "Bibata-Modern-Ice" "The name of the cursor theme to apply.";
      package = mkOpt types.package pkgs.bibata-cursor-ice "The package to use for the cursor theme.";
      size = mkOpt types.int 32 "The size of the cursor.";
    };

    icon = {
      name = mkOpt types.str "Papirus-Dark" "The name of the icon theme to apply.";
      package = mkOpt types.package (
        pkgs.catppuccin-papirus-folders.override {
          accent = "blue";
          flavor = "macchiato";
        }
      ) "The package to use for the icon theme.";
    };
  };

  config = mkIf cfg.enable (
    lib.optionalAttrs (lib.hasAttrByPath [ "stylix" ] options) {
      stylix = {
        enable = true;
        base16Scheme = "${inputs.stylix.inputs.tinted-schemes}/base16/${cfg.theme}.yaml";

        fonts = {
          sizes = {
            desktop = 12;
            applications = 12;
            terminal = 13;
            popups = 12;
          };

          serif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          sansSerif = {
            package = pkgs.noto-fonts;
            name = "Noto Sans";
          };
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
        icons = {
          enable = true;
          inherit (cfg.icon) package;
          dark = cfg.icon.name;
          light = cfg.icon.name;
        };

        polarity = "dark";

        opacity = {
          desktop = 1.0;
          applications = 0.90;
          terminal = 0.90;
          popups = 1.0;
        };

        targets = {

          bat.enable = !(isThemedBy "bat");
          btop.enable = !(isThemedBy "btop");
          cava.enable = !(isThemedBy "cava");
          fish.enable = !(isThemedBy "fish");
          foot.enable = !(isThemedBy "foot");
          fzf.enable = !(isThemedBy "fzf");
          ghostty.enable = !(isThemedBy "ghostty");
          kitty.enable = !(isThemedBy "kitty");
          lazygit.enable = !(isThemedBy "lazygit");
          neovim.enable = !(isThemedBy "neovim");
          tmux.enable = !(isThemedBy "tmux");
          vesktop.enable = !(isThemedBy "vesktop");
          yazi.enable = !(isThemedBy "yazi");
          gtk.enable = false;
          qt.enable = !(isThemedBy "qt");
        };

        cursor = lib.mkOptionDefault cfg.cursor;
      };

      home = lib.mkIf (!anyCuratedTheme) {
        pointerCursor = {
          enable = true;
          inherit (cfg.cursor) name package size;
        };
      };

      gtk.gtk3 = {
        font = null;
      };
    }
  );
}
