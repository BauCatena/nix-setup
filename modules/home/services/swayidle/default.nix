{ pkgs, config, lib, ... }:
let
  cfg = config.bautinix.services.swayidle;
in
{
  options.bautinix.services.swayidle = {
    enable = lib.mkEnableOption "swayidle locker";
  };

  config = lib.mkIf config.bautinix.programs.graphical.screenlockers.swaylock.enable {
    services.swayidle = {
      enable = true;
      timeouts = [
        # Timeouts are expressed in seconds
        {
          timeout = 600;
          command = "swaylock -f";
        }
        {
          timeout = 900;
          command = "systemctl suspend"; 
        }
      ];
      events = {
        before-sleep = "swaylock -f";
        lock = "swaylock -f";
      };
    };
  };
}
