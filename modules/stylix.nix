{ pkgs, ... }: {
  stylix = {
    enable = true;
    polarity = "dark";
    image = ./../assets/wallpaper.png;

    targets = {
      grub.enable = true;
      plymouth.enable = true;
    };

    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
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
  };

  # yazi config is symlinked from dotfiles; stylix cannot write theme.toml there
  home-manager.users.bauti = {
    stylix.targets.yazi.enable = false;
  };
}
