{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  inherit (lib.bautinix) force-attrs;

  cfg = config.bautinix.theme.nord;
  inherit ((import ./colors.nix)) palette;
in
{
  config = mkIf cfg.enable {
    programs = {
 
#      kitty.extraConfig = ''
#        include ${pkgs.kitty-themes}/share/kitty-themes/themes/Nord.conf
#      '';

      neovim.plugins = [
        pkgs.vimPlugins.nord-nvim
      ];

      tmux.plugins = [
        { plugin = pkgs.tmuxPlugins.nord; }
      ];

      yazi = {
        theme = lib.mkForce (import ./yazi/theme.nix { inherit (import ./colors.nix) palette; });
      };

        starship = {
        settings = mkDefault (
          let
            schemas = import ./starship/modules.nix { inherit palette; };
          in
          schemas.default
        );

      };      swaylock.settings =
        mkIf config.bautinix.programs.graphical.screenlockers.swaylock.enable
          (force-attrs {
            screenshots = true;
            effect-blur = "3x2";
            clock = true;
            indicator = true;
            indicator-radius = 100;
            font = "Victor Mono";

            key-hl-color = palette.color9.hex;
            bs-hl-color = palette.color11.hex;
            caps-lock-key-hl-color = palette.color12.hex;
            caps-lock-bs-hl-color = palette.color11.hex;

            separator-color = palette.color0.hex;

            inside-color = palette.color1.hex;
            inside-clear-color = palette.color1.hex;
            inside-caps-lock-color = palette.color1.hex;
            inside-ver-color = palette.color1.hex;
            inside-wrong-color = palette.color1.hex;

            ring-color = palette.color2.hex;
            ring-clear-color = palette.color9.hex;
            ring-caps-lock-color = palette.color12.hex;
            ring-ver-color = palette.color2.hex;
            ring-wrong-color = palette.color11.hex;

            line-color = palette.color9.hex;
            line-clear-color = palette.color9.hex;
            line-caps-lock-color = palette.color12.hex;
            line-ver-color = palette.color0.hex;
            line-wrong-color = palette.color11.hex;

            text-color = palette.color5.hex;
            text-clear-color = palette.color5.hex;
            text-caps-lock-color = palette.color5.hex;
            text-ver-color = palette.color5.hex;
            text-wrong-color = palette.color5.hex;
      });
    };
  };
}
