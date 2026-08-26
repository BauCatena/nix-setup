{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) getExe mkIf;

  cfg = config.bautinix.home.programs.terminal.tools.bat;
in
{
  options.bautinix.home.programs.terminal.tools.bat = {
    enable = lib.mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        style = "auto,header-filesize";
      };

      extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (
        with pkgs.bat-extras;
        [
          batdiff
          batgrep
          batman
          batpipe
          batwatch
          prettybat
        ]
      );
    };

    home.shellAliases = {
      cat = "${getExe pkgs.bat} --style=plain";
    };
  };
}
