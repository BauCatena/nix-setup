{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.bautinix.programs.graphical.apps.hyprfm;
in
{
  options.bautinix.programs.graphical.apps.hyprfm = {
    enable = mkEnableOption "hyprfm";
  };

  config = mkIf cfg.enable {

    bautinix.services.udisks2.enable = true;
 
      environment.systemPackages = [
        (inputs.hyprfm.packages.${pkgs.system}.default.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            echo "import QtQuick; Item {}" > src/qml/icons/IconColumns3.qml
          '';
        }))
      ];
      };
}
