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
          };
          sessionPackages = lib.mkForce[ pkgs.niri ];
          defaultSession = "niri";
          autoLogin = {
              enable = true;
              user = "bauti";
            };
        };
      };
  };
}
