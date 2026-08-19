{ pkgs, ... }: 
let

niriSettings = "${dotfiles}/nixosConfig/nixosConfig/modules/home/programs/graphical/wm/niri/settings";

in
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        # Lock screen after 5 minutes (300 seconds)
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        # Turn off display after 10 minutes (600 seconds)
        timeout = 600;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors"; # Or sway/hyprland equivalent
      }
    ];
    events = {
      before-sleep = "${niriSettings}/scripts/lock.sh";
      lock = "${niriSettings}/scripts/lock.sh";
    };

     };
}
