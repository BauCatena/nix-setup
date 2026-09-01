{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.tools.yazi;
in
{
  options.bautinix.programs.terminal.tools.yazi = {
    enable = mkEnableOption "yazi";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      yazi
    ];

    programs.yazi = {
      enable = true;

#      flavors = {
 #       nord = pkgs.yaziPlugins.nord; 
 #     };

  #    theme = lib.importTOML ./theme.toml;
    };
  };
}
