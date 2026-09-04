{ inputs }:
let
  inherit (inputs.nixpkgs.lib) getExe;
in
rec {
  mkColorScheme = name: colors: {
    inherit name colors;
    type = "colorScheme";
  };

  getColors = scheme: scheme.colors or { };

  variants = {
    light = "light";
    dark = "dark";
  };

  wallpaperTheme =
    config:
    if
      config ? bautinix
      && config.bautinix ? theme
      && config.bautinix.theme ? wallpaper
      && config.bautinix.theme.wallpaper ? theme
    then
      config.bautinix.theme.wallpaper.theme
    else
      "catppuccin";

  wallpaperDir =
    {
      config,
      pkgs,
      theme ? null,
    }:
    let
      themeName = if theme != null then theme else wallpaperTheme config;
      prefix = if themeName == null || themeName == "" then "" else "${themeName}/";
    in
    "${pkgs.bautinix.wallpapers}/share/wallpapers/${prefix}";

  wallpaperPath =
    {
      config,
      pkgs,
      name,
      theme ? null,
    }:
    let
      themeName = if theme != null then theme else wallpaperTheme config;
      prefix = if themeName == null || themeName == "" then "" else "${themeName}/";
    in
    "${pkgs.bautinix.wallpapers}/share/wallpapers/${prefix}${name}";

  wallpaperPaths =
    {
      config,
      pkgs,
      names,
      theme ? null,
    }:
    map (
      name:
      wallpaperPath {
        inherit
          config
          pkgs
          theme
          name
          ;
      }
    ) names;

  # Migrated SCSS compilation utility
  # a function that takes a theme name and a source file and compiles it to CSS
  # compileSCSS "theme-name" "path/to/theme.scss" -> "$out/theme-name.css"
  # adapted from <https://github.com/spikespaz/dotfiles>
  compileSCSS =
    pkgs:
    {
      name,
      source,
      args ? "-t expanded",
    }:
    "${
      pkgs.runCommandLocal name { } ''
        mkdir -p $out
        ${getExe pkgs.sassc} ${args} '${source}' > $out/${name}.css
      ''
    }/${name}.css";
}
