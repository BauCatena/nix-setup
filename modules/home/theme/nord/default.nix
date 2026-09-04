{
  config,
  lib,
  pkgs,
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

  cfg = config.bautinix.theme.nord;
  palette = import ./colors.nix;
  t3codeTheme = import ../t3code.nix {
    appearance = "dark";
    id = "bautinix-nord";
    name = "Nord";
    accent = palette.palette.nord10.hex;
    accentForeground = palette.palette.nord6.hex;
    border = palette.palette.nord3.hex;
    canvas = palette.palette.nord0.hex;
    chrome = palette.palette.nord0.hex;
    error = palette.palette.nord11.hex;
    secondary = palette.palette.nord8.hex;
    statusForeground = palette.palette.nord0.hex;
    success = palette.palette.nord14.hex;
    surface = palette.palette.nord1.hex;
    surfaceOverlay = palette.palette.nord3.hex;
    surfaceRaised = palette.palette.nord2.hex;
    text = palette.palette.nord6.hex;
    textMuted = palette.palette.nord4.hex;
    warning = palette.palette.nord13.hex;
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

  options.bautinix.theme.nord = {
    enable = mkEnableOption "Nord theme for applications";

    variant = mkOption {
      type = types.enum [
        "default"
        "darker"
        "bluish"
        "polar"
      ];
      default = "default";
      description = "Nordic theme variant to use for GTK and Qt.";
    };
  };

  config = mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !config.bautinix.theme.catppuccin.enable;
            message = "Nord and Catppuccin themes cannot be enabled at the same time";
          }
        ];

        bautinix = {
          theme = {
            wallpaper = {
              theme = mkDefault "nord";
              primary = mkDefault "nixos.png";
              secondary = mkDefault "Abstract-Nord.png";
              lock = mkDefault "Abstract-Nord.png";
              list = mkDefault [
                "Abstract-Nord.png"
                "BirdNord.png"
                "Minimal-Nord.png"
                "arctic-landscape.png"
                "chemical_nord.png"
                "ign-0001.png"
                "ign-0011.png"
                "nixos.png"
              ];
            };
            stylix = {
              enable = true;
              theme = "nord";

              cursor = {
                name = "Bibata-Modern-Ice";
                package = pkgs.bibata-cursors;
                size = 24;
              };

              icon = {
                name = "Nordzy-dark";
                package = pkgs.nordzy-icon-theme;
              };
            };
          };
        };

        home = {
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
