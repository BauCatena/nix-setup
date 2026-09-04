{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.programs.terminal.tools.yazi;

in
{
  options.bautinix.programs.terminal.tools.yazi = {
    enable = lib.mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;

      package =
        pkgs.yazi.override {
          _7zz = pkgs._7zz-rar; # Support for RAR extraction
          extraPackages =
            let
              optionalPluginPackage =
                plugin: package: lib.optional (builtins.hasAttr plugin config.programs.yazi.plugins) package;
            in
            (with pkgs; [
              atool
              exiftool
              mediainfo
              unar
              undmg
            ])
            ++ optionalPluginPackage "ouch" pkgs.ouch
            ++ optionalPluginPackage "duckdb" pkgs.duckdb
            ++ optionalPluginPackage "piper" pkgs.bat
            ++ optionalPluginPackage "piper" pkgs.eza
            ++ optionalPluginPackage "piper" pkgs.glow
            ++ optionalPluginPackage "piper" pkgs.xlsx2csv
            ++ optionalPluginPackage "restore" pkgs.trash-cli
            ++ [
              pkgs.dragon-drop
            ];
        };

      enableZshIntegration = true;
      shellWrapperName = "y";

      inherit (import ./init.nix { inherit config lib; }) initLua;

      plugins = {
      }
      // lib.optionalAttrs ( true ) {
        inherit (pkgs.yaziPlugins) restore;
      }
      // lib.optionalAttrs config.bautinix.theme.nord.enable {
        inherit (pkgs.yaziPlugins) nord;
      }
      // lib.optionalAttrs config.bautinix.theme.catppuccin.enable {
        inherit (pkgs.yaziPlugins) yatline-catppuccin;
      };
    };
  };
}
