{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.ripgrep;
  inherit (lib) mkEnableOption mkForce mkIf getExe;
in
{
  options.bautinix.programs.terminal.tools.ripgrep.enable =
    mkEnableOption "ripgrep";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ripgrep ];

    programs.zsh.shellAliases = {
      grep = mkForce "${getExe pkgs.ripgrep}";
    };
  };
}
