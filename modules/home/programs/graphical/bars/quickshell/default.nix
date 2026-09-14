{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.graphical.bars.quickshell;
in
{
  options.bautinix.programs.graphical.bars.quickshell = {
    enable = mkEnableOption "quickshell";
  };

  config = mkIf cfg.enable {

    programs.quickshell.enable = true;
    programs.quickshell.package = pkgs.symlinkJoin {
      name = "quickshell-wrapped";
      paths = [ pkgs.quickshell ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/quickshell \
          --set QT_QUICK_CONTROLS_STYLE "Basic" \
          --set QT_QPA_PLATFORMTHEME ""
        '';
      };

    xdg.configFile."quickshell".source = ./settings;
  };
}
