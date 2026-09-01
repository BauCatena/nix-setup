{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.bautinix.theme.nord;
in
{
  imports = [
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
        bautinix.theme = {
          enable = true;
          name = "nord";
          package = pkgs.nordic;

          cursor = {
            name = "Bibata-Modern-Ice";
            package = pkgs.bibata-cursors;
            size = 24;
          };
        };

        assertions = [
          {
            assertion = !config.bautinix.theme.catppuccin.enable;
            message = "Nord and Catppuccin themes cannot be enabled at the same time";
          }
          {
            assertion = !config.bautinix.theme.tokyonight.enable;
            message = "Nord and Tokyonight themes cannot be enabled at the same time";
          }
        ];
      }
    ]
  );
}
