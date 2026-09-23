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

  nord = { inherit palette; };

  t3codeTheme = import ../t3code.nix {
    appearance = "dark";
    id = "bautinix-nord";
    name = "Nord";
    accent = nord.palette.nord10.hex;
    accentForeground = nord.palette.nord6.hex;
    border = nord.palette.nord3.hex;
    canvas = nord.palette.nord0.hex;
    chrome = nord.palette.nord0.hex;
    error = nord.palette.nord11.hex;
    secondary = nord.palette.nord8.hex;
    statusForeground = nord.palette.nord0.hex;
    success = nord.palette.nord14.hex;
    surface = nord.palette.nord1.hex;
    surfaceOverlay = nord.palette.nord3.hex;
    surfaceRaised = nord.palette.nord2.hex;
    text = nord.palette.nord6.hex;
    textMuted = nord.palette.nord4.hex;
    warning = nord.palette.nord13.hex;
  };

  stylixAvailable = options ? stylix;
in
{
  imports = [
    ./apps.nix
    ./gtk.nix
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
          programs = {
            graphical = {
              browsers = {
                firefox.policies.ExtensionSettings = mkIf config.bautinix.programs.graphical.browsers.firefox.enable {
                  "${pkgs.firefox-addons.kristofferhagen-nord-theme.addonId}" = {
                    installation_mode = "force_installed";
                    install_url = "file://${pkgs.firefox-addons.kristofferhagen-nord-theme}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${pkgs.firefox-addons.kristofferhagen-nord-theme.addonId}.xpi";
                  };
                };
              };
            };
          };
          theme = {
            wallpaper = {
              theme = mkDefault "nord";
              primary = mkDefault "ign-0011.png";
              secondary = mkDefault "Abstract-Nord.png";
              lock = mkDefault "Abstract-Nord.png";
              list = mkDefault [
                "Abstract-Nord.png"
                "BirdNord.png"
                "Minimal-Nord.png"
                "arctic-landscape.png"
                "chemical_nord.png"
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
