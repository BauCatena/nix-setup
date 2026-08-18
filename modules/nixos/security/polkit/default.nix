{
  config,
  lib,
  pkgs,

  ...
}:
let
  cfg = config.bautinix.nixos.security.polkit;
in
{
  options.bautinix.nixos.security.polkit = {
    enable = lib.mkEnableOption "polkit";
    debug = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable polkit debugging/logging.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Create directories to suppress polkit warnings
    systemd.tmpfiles.rules = [
      "d /etc/polkit-1/actions 0755 root root -"
      "d /run/polkit-1/actions 0755 root root -"
      "d /usr/local/share/polkit-1/actions 0755 root root -"
    ];
    security.polkit = {
      enable = true;

      extraConfig = lib.mkIf cfg.debug ''
        /* Log authorization checks. */
        polkit.addRule(function(action, subject) {
          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
        });
      '';
    };
  };
}
