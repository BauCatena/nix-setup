{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe' mkForce stringAfter;

  cfg = config.bautinix.display-managers.sddm;

in
{
  options.bautinix.display-managers.sddm = {
    enable = lib.mkEnableOption "sddm";
  };

config = mkIf cfg.enable {
      services = {
        displayManager = {
          sddm = {
            enable = true;
            wayland.enable = true;

            setupScript = ''
              ${pkgs.xrdb}/bin/xrdb -merge - <<EOF
              Xcursor.theme: Bibata-Modern-Classic
              Xcursor.size: 24
              EOF
              '';
          };
          defaultSession = "niri";

          sessionPackages = [ pkgs.niri ];

        };
      };
  };
}
