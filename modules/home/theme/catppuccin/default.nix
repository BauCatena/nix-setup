{
  config,
  lib,
  pkgs,
  inputs,
  options,
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

  cfg = config.bautinix.theme.catppuccin;

  inherit (inputs) yazi-flavors;
  palette = import ./colors.nix;
  inherit (palette) colors;
  catppuccinColors =
    (lib.importJSON "${config.catppuccin.sources.palette}/palette.json").${cfg.flavor}.colors;

  t3codeTheme = import ../t3code.nix {
    appearance = if cfg.flavor == "latte" then "light" else "dark";
    id = "bautinix-catppuccin-${cfg.flavor}";
    name = "Catppuccin ${lib.bautinix.capitalize cfg.flavor}";
    accent = catppuccinColors.${cfg.accent}.hex;
    accentForeground = catppuccinColors.base.hex;
    border = catppuccinColors.surface2.hex;
    canvas = catppuccinColors.base.hex;
    chrome = catppuccinColors.mantle.hex;
    error = catppuccinColors.red.hex;
    secondary = catppuccinColors.teal.hex;
    statusForeground = catppuccinColors.crust.hex;
    success = catppuccinColors.green.hex;
    surface = catppuccinColors.surface0.hex;
    surfaceOverlay = catppuccinColors.surface2.hex;
    surfaceRaised = catppuccinColors.surface1.hex;
    text = catppuccinColors.text.hex;
    textMuted = catppuccinColors.subtext0.hex;
    warning = catppuccinColors.yellow.hex;
  };
  
  stylixAvailable = options ? stylix;
in
{
  imports = [
    ./apps.nix
    ./gtk.nix
    ./qt.nix
    inputs.catppuccin.homeModules.catppuccin
  ];

  options.bautinix.theme.catppuccin = {
    enable = mkEnableOption "catppuccin theme for applications";

    accent = mkOption {
      type = types.enum [
        "rosewater"
        "flamingo"
        "pink"
        "mauve"
        "red"
        "maroon"
        "peach"
        "yellow"
        "green"
        "teal"
        "sky"
        "sapphire"
        "blue"
        "lavender"
      ];
      default = "blue";
      description = ''
        An optional theme accent.
      '';
    };

    flavor = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = "macchiato";
      description = ''
        An optional theme flavor.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.catppuccin.override {
        inherit (cfg) accent;
        variant = cfg.flavor;
      };
      description = "Catppuccin package configured with the selected accent and flavor.";
    };
  };

  config = lib.mkMerge [
    # catppuccin/nix migration: `enable` is becoming a global on/off toggle and
    # `autoEnable` the "enroll every port" switch. Pin both explicitly so behavior
    # stays stable and the deprecation warning is silenced on every profile,
    # including hosts not using the catppuccin theme. We never auto-enroll; the
    # ports below are cherry-picked when the theme is active.
    (lib.optionalAttrs (inputs ? catppuccin && inputs.catppuccin ? homeModules) {
      catppuccin = {
        inherit (cfg) enable;
        autoEnable = false;
      };
    })

    (mkIf cfg.enable (
      lib.mkMerge [
        {
          assertions = [
            {
              assertion = !config.bautinix.theme.nord.enable;
              message = "Nord and Catppuccin themes cannot be enabled at the same time";
            }
          ];

          bautinix = {
            theme = {
              wallpaper = {
                theme = mkDefault "catppuccin";
                primary = mkDefault "catppuccin-pacman.jpg";
                secondary = mkDefault "catppuccin-floyd.png";
                lock = mkDefault "catppuccin-space.png";
                list = mkDefault [
                  "flatppuccin_macchiato.png"
                  "cat_pacman.png"
                  "cat-sound.png"
                ];
              };
              stylix = {
                enable = true;
                theme = lib.mkDefault "catppuccin-macchiato";

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

          programs = {
            codex.settings.desktop = {
              appearanceTheme = "dark";
              appearanceDarkCodeThemeId = "catppuccin";
              appearanceDarkChromeTheme = {
                surface = palette.colors.base.hex;
                ink = palette.colors.text.hex;
                accent = palette.colors.${cfg.accent}.hex;
                contrast = 45;
                fonts = { };
                opaqueWindows = false;
                semanticColors = {
                  diffAdded = palette.colors.green.hex;
                  diffRemoved = palette.colors.red.hex;
                  skill = palette.colors.${cfg.accent}.hex;
                };
              };
            };

            t3code.clientSettings.declarativeTheme = t3codeTheme;
          };

          home = {
            sessionVariables = {
              CURSOR_THEME = config.bautinix.theme.gtk.cursor.name;
            };
            pointerCursor = {
              enable = true;
              inherit (config.bautinix.theme.gtk.cursor) name package size;
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
    ))
  ];
}
