{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.qemu;
in
{
  options.bautinix.programs.graphical.apps.qemu = {
    enable = mkEnableOption "qemu and virtualisation";
  };

  config = mkIf cfg.enable {

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;       };
    };

    programs.virt-manager.enable = true;

    programs.dconf.enable = true;

    users.users.bauti.extraGroups = [ "libvirtd" "wheel" ];

    environment.systemPackages = with pkgs; [
      qemu
      virt-manager
      virt-viewer
      spice-vdagent 
    ];
  };
}
