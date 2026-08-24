{ config, lib, pkgs, ... }:

{
 
  bautinix.nixos.programs.graphical.addons.awww.enable = true;
  bautinix.nixos.programs.graphical.addons.brightnessctl.enable = true;
  bautinix.nixos.programs.graphical.addons.polkit_gnome.enable = true;
  bautinix.nixos.programs.terminal.tools.powertop.enable = true;
  bautinix.nixos.programs.terminal.tools.net-tools.enable = true;
  bautinix.nixos.programs.terminal.tools.fzf.enable = true;
  bautinix.nixos.programs.terminal.tools.gcc.enable = true;
  bautinix.nixos.programs.terminal.tools.iw.enable = true;
  bautinix.nixos.programs.graphical.wms.niri.enable = true;


  bautinix.nixos.services.udisks2.enable = true;

  bautinix.nixos.hardware.audio.enable = true;
  bautinix.nixos.hardware.bluetooth.enable = true;
  bautinix.nixos.hardware.cpu.amd.enable = true;
  bautinix.nixos.hardware.opengl.enable = true;
  bautinix.nixos.hardware.power.enable = true;
  bautinix.nixos.hardware.storage.enable = true;
  bautinix.nixos.hardware.tpm.enable = true;

  bautinix.nixos.security.sops.enable = true;
  bautinix.nixos.security.polkit.enable = true;
  bautinix.nixos.security.keyring.enable = true;
  bautinix.nixos.security.rtkit.enable = true;

  bautinix.nixos.display-managers.sddm.enable = true;

  bautinix.nixos.nix.enable = true;

}
