{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.fonts;
in
{
  options.bautinix.fonts = {
    sans = mkOpt types.str "Noto Sans" "Primary sans-serif font family";
    serif = mkOpt types.str "Noto Sans" "Primary serif font family";
    mono = mkOpt types.str "JetBrainsMono Nerd Font" "Primary monospace Nerd Font family";

    stacks = {
      editor = mkOpt types.str "${cfg.mono}, monospace" "Font-family stack for code editors";
      ui = mkOpt types.str "${cfg.sans}, sans-serif" "Font-family stack for UI text";
      terminal = mkOpt types.str cfg.mono "Font-family stack for terminals";
    };
  };
}
