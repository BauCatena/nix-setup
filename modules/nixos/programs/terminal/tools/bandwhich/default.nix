{ config, lib, ... }:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.programs.terminal.tools.bandwhich;
in
{
  options.bautinix.nixos.programs.terminal.tools.bandwhich = {
    enable = lib.mkEnableOption "bandwhich";
  };

  config = mkIf cfg.enable {
    programs.bandwhich = {
      enable = true;
    };
  };
}
