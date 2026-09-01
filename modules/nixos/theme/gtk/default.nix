{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.theme.gtk;
in
{
  options.bautinix.theme.gtk = with types; {
    enable = lib.mkEnableOption "customizing GTK and apply themes";

    theme = {
      name = mkOpt str "catppuccin-macchiato-blue-standard" "The name of the GTK theme to apply.";
      package = mkOpt package (pkgs.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "macchiato";
      }) "The package to use for the theme.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      sessionVariables = {
        GTK_THEME = cfg.theme.name;
      };
    };

  };
}
