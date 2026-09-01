{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    mkOption
    types
    ;

  cfg = config.bautinix.theme.tokyonight;
  palette = import ./colors.nix;
  colors = palette.getVariant cfg.variant;
  t3codeTheme = import ../t3code.nix {
    appearance = if cfg.variant == "day" then "light" else "dark";
    id = "bautinix-tokyonight-${cfg.variant}";
    name =
      if cfg.variant == "night" then
        "Tokyo Night"
      else
        "Tokyo Night ${lib.bautinix.capitalize cfg.variant}";
    accent = colors.blue;
    accentForeground = if cfg.variant == "day" then "#ffffff" else colors.bg_dark1;
    border = colors.blue7;
    canvas = colors.bg;
    chrome = colors.bg_dark;
    error = colors.red;
    secondary = colors.cyan;
    statusForeground = if cfg.variant == "day" then "#1a1b26" else colors.bg_dark1;
    success = colors.green;
    surface = colors.bg_dark;
    surfaceOverlay = colors.dark3;
    surfaceRaised = colors.bg_highlight;
    text = colors.fg;
    textMuted = colors.comment;
    warning = colors.yellow;
  };
  
  stylixAvailable = options ? stylix;
in
{
  imports = [
    ./apps.nix
    ./gtk.nix
    ./starship.nix
    ./qt.nix
  ];

  options.bautinix.theme.tokyonight = {
    enable = mkEnableOption "Tokyonight theme for applications";

    variant = mkOption {
      type = types.enum [
        "day"
        "night"
        "storm"
        "moon"
      ];
      default = "night";
      description = "Tokyonight theme variant to use.";
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !config.bautinix.theme.catppuccin.enable;
            message = "Tokyonight and Catppuccin themes cannot be enabled at the same time";
          }
          {
            assertion = !config.bautinix.theme.nord.enable;
            message = "Tokyonight and Nord themes cannot be enabled at the same time";
          }
        ];

        bautinix = {
          theme = {
            wallpaper = {
              theme = mkDefault "tokyonight";
              primary = mkDefault "pacman_upscayl_realesrgan-x4plus_x2.png";
              secondary = mkDefault "game_upscayl_realesrgan-x4plus_x2.png";
              lock = mkDefault "tron_upscayl_realesrgan-x4plus_x2.png";
              list = mkDefault [
                "comic_upscayl_realesrgan-x4plus_x2.png"
                "controls_upscayl_realesrgan-x4plus_x2.png"
                "game_upscayl_realesrgan-x4plus_x2.png"
                "gamveover_upscayl_realesrgan-x4plus_x2.png"
                "heroes_upscayl_realesrgan-x4plus_x2.png"
                "invader_upscayl_realesrgan-x4plus_x2.png"
                "joystick_upscayl_realesrgan-x4plus_x2.png"
                "js_upscayl_realesrgan-x4plus_x2.png"
                "pacman3_upscayl_realesrgan-x4plus_x2.png"
                "pacman_upscayl_realesrgan-x4plus_x2.png"
                "smile_upscayl_realesrgan-x4plus_x2.png"
                "spookyjs_upscayl_realesrgan-x4plus_x2.png"
                "tron_upscayl_realesrgan-x4plus_x2.png"
                "tv_upscayl_realesrgan-x4plus_x2.png"
                "void_upscayl_realesrgan-x4plus_x2.png"
              ];
            };
            stylix = {
              enable = true;
              theme = "tokyo-night-dark";

              cursor = {
                name = "Bibata-Modern-Ice";
                package = pkgs.bibata-cursors;
                size = 24;
              };

              icon = {
                name = "Papirus-Dark";
                package = pkgs.papirus-icon-theme;
              };
            };
          };
        };


        home = {
          pointerCursor = {
            enable = true;
            inherit (config.bautinix.theme.gtk.cursor) name package size;
          };

          sessionVariables = {
            CURSOR_THEME = config.bautinix.theme.gtk.cursor.name;
          };
        };
      }

      (lib.optionalAttrs stylixAvailable {
        stylix.image = lib.bautinix.theme.wallpaperPath {
          inherit config pkgs;
          name = config.bautinix.theme.wallpaper.primary;
        };
      })
    ]
  );
}
