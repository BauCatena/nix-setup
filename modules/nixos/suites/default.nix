{ config, lib, pkgs, ... }:

{
 
  bautinix.nixos.programs.terminal.tools.powertop.enable = true;
  bautinix.nixos.programs.terminal.tools.net-tools.enable = true;
  bautinix.nixos.programs.terminal.tools.fzf.enable = true;
  bautinix.nixos.programs.terminal.tools.gcc.enable = true;
  bautinix.nixos.programs.terminal.tools.iw.enable = true;

  bautinix.nixos.nix.enable = true;

}
