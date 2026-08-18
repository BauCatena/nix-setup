{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.home.programs.terminal.tools.atuin; 
in
{
  options.bautinix.home.programs.terminal.tools.atuin = {
    enable = mkEnableOption "atuin";
  };

  config = mkIf cfg.enable {

      programs.atuin = {
          enable = true;

          settings = {

              auto_sync = false;
              db_path = ".config/atuin/db";
            };

        };

    };
}
