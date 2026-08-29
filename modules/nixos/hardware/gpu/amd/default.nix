{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.hardware.gpu.amd;
in
{
  options.bautinix.hardware.gpu.amd = {
    enable = lib.mkEnableOption "support for amdgpu";
    enableRocmSupport = lib.mkEnableOption "support for rocm";
    enableNvtop = lib.mkEnableOption "install nvtop for amd";
    
    # Added an explicit toggle for overdrive so it's off by default on laptops
    enableOverdrive = lib.mkOption {
      type = lib.types.bool;
      default = false; # Safe default for laptops! Set to true only on desktop rigs with discrete GPUs.
      description = "Enable AMDGPU overdrive and ppfeaturemask (for desktop discrete cards).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        amdgpu_top
      ]
      ++ lib.optionals cfg.enableNvtop [
        nvtopPackages.amd
      ];

    hardware = {
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
        
        # Only apply overdrive if explicitly requested (e.g., on a desktop)
        overdrive = mkIf cfg.enableOverdrive {
          enable = true;
          ppfeaturemask = "0xffffffff";
        };
      };

      graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vulkan-tools
        ];
      };
    };

    nixpkgs.config.rocmSupport = cfg.enableRocmSupport;

    # Only apply performance level udev rules if overdrive is enabled
    services.udev.extraRules = mkIf cfg.enableOverdrive ''
      KERNEL=="card[0-9]", SUBSYSTEM=="drm", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod 666 /sys/class/drm/%k/device/power_dpm_force_performance_level"
    '';
  };
}
