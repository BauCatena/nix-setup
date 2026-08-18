{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;

  cfg = config.bautinix.nixos.system.fonts;
in
{
  options.bautinix.nixos.system.fonts = {
    enable = mkEnableOption "Enable system font configuration";
    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "List of font packages to install system-wide.";
    };
  };

  config = mkIf cfg.enable {
    fonts = {
        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          nerd-fonts.symbols-only
          nerd-fonts.jetbrains-mono
        ];

      enableDefaultPackages = true;

      fontconfig = {
        antialias = true;
        hinting.enable = true;

        defaultFonts =
          let
            # Symbols and emojis are added as fallbacks to all categories
            common = [
              "Symbols Nerd Font"
              "Noto Color Emoji"
            ];
          in
          lib.mapAttrs (_: fonts: fonts ++ common) {
            serif = [ "Noto Serif" ];
            sansSerif = [ "Noto Sans" ];
            emoji = [ ];
            monospace = [ 
              "JetBrainsMono Nerd Font" 
            ];
          };
      };

      fontDir = {
        enable = true;
        decompressFonts = true;
      };
    };
  };
}
