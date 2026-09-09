{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe' mkForce stringAfter mkDefault types;

  cfg = config.bautinix.display-managers.sddm;

in
{
  options.bautinix.display-managers.sddm = {
    enable = lib.mkEnableOption "sddm";

    defaultSession = lib.mkOption {
      type = types.str;
      default = "plasma";
      description = "The default desktop session to launch.";
    };

    autoLogin = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Wheter to autolog or not.";
    };
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
          defaultSession = cfg.defaultSession;

          autoLogin = {
            enable = cfg.autoLogin;
            user = "bauti";
          };

          sessionPackages = [ pkgs.niri ];

        };
      };
  };
}
