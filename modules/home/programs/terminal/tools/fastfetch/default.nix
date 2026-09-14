{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.bautinix.programs.terminal.tools.fastfetch;

  schemas = import ./schemas/modules.nix;
in
{
  options.bautinix.programs.terminal.tools.fastfetch = {
    enable = mkEnableOption "fastfetch";
  };

  config = mkIf cfg.enable {

    programs.fastfetch = {
      enable = true;

      settings = lib.mkDefault schemas.default;
    };
  };
}
