{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
    ;

  inherit (lib.bautinix) disabled enabled;

  cfg = config.bautinix.theme.catppuccin;

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
  fzfColors = {
    "bg+" = colors.surface0.hex;
    bg = colors.base.hex;
    border = colors.overlay0.hex;
    fg = colors.text.hex;
    "fg+" = colors.text.hex;
    header = colors.${cfg.accent}.hex;
    hl = colors.${cfg.accent}.hex;
    "hl+" = colors.${cfg.accent}.hex;
    info = colors.${cfg.accent}.hex;
    label = colors.text.hex;
    marker = colors.${cfg.accent}.hex;
    pointer = colors.${cfg.accent}.hex;
    prompt = colors.${cfg.accent}.hex;
    selected-bg = colors.surface1.hex;
    spinner = colors.rosewater.hex;
  };
  ghDashTheme = {
    theme.colors = {
      background.selected = colors.surface0.hex;
      border = {
        faint = colors.surface0.hex;
        primary = colors.${cfg.accent}.hex;
        secondary = colors.surface1.hex;
      };
      text = {
        error = colors.red.hex;
        faint = colors.subtext1.hex;
        inverted = colors.crust.hex;
        primary = colors.text.hex;
        secondary = colors.${cfg.accent}.hex;
        success = colors.green.hex;
        warning = colors.yellow.hex;
      };
    };
  };

  in
{
  imports = [
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
                primary = mkDefault "flatppuccin_macchiato.png";
                secondary = mkDefault "cat-sound.png";
                lock = mkDefault "flatppuccin_macchiato.png";
                list = mkDefault [
                  "flatppuccin_macchiato.png"
                  "cat_pacman.png"
                  "cat-sound.png"
                ];
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
        }
        (lib.optionalAttrs (inputs ? catppuccin && inputs.catppuccin ? homeModules) {
          catppuccin = {
            # enable + autoEnable are pinned unconditionally above; here we only
            # cherry-pick the ports that should receive catppuccin styling.
            accent = "blue";
            flavor = "macchiato";

            # keep-sorted start block=yes
            atuin = enabled;
            bat = enabled;
            btop = enabled;
            cava = enabled;
            # Static local settings avoid upstream generated palette imports during eval.
            fzf = disabled;
            # Static local settings avoid upstream generated YAML conversion during eval.
            kitty = enabled;
            lazygit = {
              enable = true;
              inherit (cfg) accent;
            };
            nvim = enabled;
            # tmux = enabled;
            # NOTE: uses remote url import
            # I already have a local file
            # vesktop = enabled;
            # keep-sorted end
          }
          // lib.optionalAttrs ( true ) {
              # foot = enabled;
            kvantum = {
              enable = true;
              inherit (cfg) accent;
            };
          };
        })

        {
          home = {
            pointerCursor = {
              enable = true;
              inherit (config.bautinix.theme.gtk.cursor) name package size;
            };
          };

          programs = {
            # Additional program settings that don't follow the common pattern
            # Codex bundles the catppuccin syntax themes upstream.
            codex.settings.tui.theme = "catppuccin-${cfg.flavor}";

            fzf.colors = mkIf config.bautinix.programs.terminal.tools.fzf.enable fzfColors;

            gh-dash.settings = mkIf config.bautinix.programs.terminal.tools.gh.enable ghDashTheme;

            vesktop.vencord = {
              settings.enabledThemes = [
                "catppuccin.css"
              ];
              # TODO: use packaged version
              themes.catppuccin = ./Catppuccin-Macchiato-BD/src.css;
            };
          };
        }
      ]
    ))
  ];
}
