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

  cfg = config.bautinix.theme.tokyonight;
in
{
  imports = [
    ./gtk.nix
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
        bautinix.theme = {
          enable = true;
          name = "tokyonight";
          package = pkgs.bautinix.tokyonight-gtk-theme;
        };

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
      }
    ]
  );
}
