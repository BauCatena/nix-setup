{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.programs.terminal.tools.bandwhich;
in
{
  options.bautinix.programs.terminal.tools.bandwhich = {
    enable = lib.mkEnableOption "bandwhich";
  };

  config = mkIf cfg.enable {
    programs.bandwhich = {
      enable = true;
    };
  };
}
