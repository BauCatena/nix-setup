{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.nixos.services.oomd;
in
{
  options.bautinix.nixos.services.oomd = {
    enable = lib.mkEnableOption "oomd";
  };

  config = mkIf cfg.enable {
    systemd = {
      oomd = {
        enable = true;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
        settings.OOM = {
          "DefaultMemoryPressureDurationSec" = "20s";
        };
      };

      # Make it that nix builds are more likely killed than important services.
      # 100 is the default for user slices and 500 is `systemd-coredumpd@`
      # nuke nix-daemon if it gets too memory hungry
      services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 350;

      # Make sure it loads after the swap is setup.
      services.systemd-oomd.after = [ "swap.target" ];
    };
  };
}
