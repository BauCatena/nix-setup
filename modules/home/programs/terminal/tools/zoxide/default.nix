{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.home.programs.terminal.tools.zoxide;
in
{
  options.bautinix.home.programs.terminal.tools.zoxide = {
    enable = lib.mkEnableOption "zoxide";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      package = pkgs.zoxide;
      enableZshIntegration = true;

      options = [ "--cmd cd" ];
    };
  };
}
