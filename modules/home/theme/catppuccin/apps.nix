{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkDefault mkIf mkMerge;
  inherit (lib.bautinix) disabled enabled;
  inherit (inputs) yazi-flavors;

  cfg = config.bautinix.theme.catppuccin;
  palette = import ./colors.nix;
  inherit (palette) colors;

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
in
{
  config = mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (inputs ? catppuccin && inputs.catppuccin ? homeModules) {
        catppuccin = {
          # enable + autoEnable are pinned unconditionally in default.nix; here we only
          # cherry-pick the ports that should receive catppuccin styling.
          accent = "blue";
          flavor = "macchiato";

          # keep-sorted start block=yes
          # NOTE: uses remote url import
          # I already have a local file
          # keep-sorted end
        }
        // lib.optionalAttrs (true) {
          waybar = enabled;
        };
      })

      {

        programs = {
          # Additional program settings that don't follow the common pattern
          # Codex bundles the catppuccin syntax themes upstream.
          codex.settings.tui.theme = "catppuccin-${cfg.flavor}";

          starship = {
            settings = mkDefault (
              let
                schemas = import ./starship/modules.nix;
              in
              schemas.default
            );
          };

          firefox.policies.ExtensionSettings = mkIf config.bautinix.programs.graphical.browsers.firefox.enable {
            "${pkgs.firefox-addons.catppuccin-mocha-mauve.addonId}" = {
              installation_mode = "force_installed";
              install_url = "file://${pkgs.firefox-addons.catppuccin-mocha-mauve}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${pkgs.firefox-addons.catppuccin-mocha-mauve.addonId}.xpi";
            };
          };

          fzf.colors = mkIf config.bautinix.programs.terminal.tools.fzf.enable fzfColors;

            tmux.plugins = [
              {
                plugin = pkgs.tmuxPlugins.catppuccin;
                extraConfig = /* Bash */ ''
                  set -g @catppuccin_flavour '${cfg.flavor}'
                  set -g @catppuccin_host 'on'
                  set -g @catppuccin_user 'on'
                '';
              }
            ];

            yazi = {
              flavors = {
                dark = "${yazi-flavors}/catppuccin-macchiato.yazi";
                light = "${yazi-flavors}/catppuccin-latte.yazi";
              };
              theme = lib.mkForce (
                {
                  flavor = {
                    dark = "dark";
                    light = "light";
                  };
                }
                // (import ./yazi/filetype.nix)
                // (import ./yazi/manager.nix)
                // (import ./yazi/theme.nix)
              );
            };

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
  );
}
