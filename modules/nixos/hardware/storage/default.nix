{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  mkOpt = type: default: description: lib.mkOption {
    inherit type default description;
  };
  mkBoolOpt = default: description: mkOpt lib.types.bool default description;

  cfg = config.bautinix.nixos.hardware.storage;
in
{
  options.bautinix.nixos.hardware.storage = {
    enable = lib.mkEnableOption "support for extra storage devices";
    ssdEnable = mkBoolOpt true "Whether or not to enable support for SSD storage devices.";
    nvmeMaxLatencyUs =
      mkOpt lib.types.int 100
        "NVMe power management: allow deeper power states but limit latency. 0 disables power management.";
    disableUsbAutoSuspend = mkBoolOpt false "Disable USB autosuspend to prevent USB device lag.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btrfs-progs
      nfs-utils
      ntfs3g
      nvme-cli
    ];

    services.fstrim.enable = lib.mkDefault cfg.ssdEnable;

    boot.kernelParams =
      lib.optionals cfg.ssdEnable [
        "nvme_core.default_ps_max_latency_us=${toString cfg.nvmeMaxLatencyUs}"
      ]
      ++ lib.optionals cfg.disableUsbAutoSuspend [
        "usbcore.autosuspend=-1"
      ];

    hardware.block = {
      defaultScheduler = "kyber";
      defaultSchedulerRotational = "bfq";
      scheduler = {
        "sd[a-z]" = "bfq";
      };
    };

    services.udev.extraRules = lib.concatStringsSep "\n" (
      lib.optionals cfg.ssdEnable [
        ''ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", KERNEL!="*p*", ATTR{queue/nr_requests}="32"''
        ''ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", KERNEL!="*p*", ATTR{queue/read_ahead_kb}="128"''
        ''ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/read_ahead_kb}="256"''
        ''ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/nr_requests}="64"''
        ''ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/read_ahead_kb}="1024"''
        ''ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/nr_requests}="256"''
      ]
    );
  };
}
