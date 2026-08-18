{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib)
    mkIf
    types
    genAttrs
    getExe
    ;
  
  mkOpt = type: default: description: lib.mkOption {
    inherit type default description;
  };

  cfg = config.bautinix.nixos.hardware.storage.btrfs;
  dedupeFilesystems = cfg.dedupeFilesystems;

  dedupeFilesystemsAttrSets = genAttrs dedupeFilesystems (name: {
    spec = "LABEL=${name}";
    hashTableSizeMB = 1024;
    verbosity = "info";
    workDir = ".beeshome";
    extraOptions = [
      "--thread-factor"
      "0.1"
      "--loadavg-target"
      "5"
    ];
  });

  escapeSystemdPath =
    s:
    let
      replacePrefix =
        p: r: s:
        (if (lib.hasPrefix p s) then r + (lib.removePrefix p s) else s);
      trim = s: lib.removeSuffix "/" (lib.removePrefix "/" s);
      normalizedPath = lib.strings.normalizePath s;
    in
    builtins.replaceStrings [ "/" ] [ "-" ] (
      replacePrefix "." (lib.strings.escapeC [ "." ] ".") (
        lib.strings.escapeC (lib.stringToCharacters " !\"#$%&'()*+,;<=>=@[\\]^`{|}~-") (
          if normalizedPath == "/" then normalizedPath else trim normalizedPath
        )
      )
    );

  hardenBtrfsScrubService =
    fsPath:
    let
      escapedFsPath = escapeSystemdPath fsPath;
      serviceName = "btrfs-scrub-${escapedFsPath}";
    in
    lib.nameValuePair serviceName {
      serviceConfig = {
        CapabilityBoundingSet = [
          "CAP_BLOCK_SUSPEND" "CAP_DAC_OVERRIDE" "CAP_DAC_READ_SEARCH" "CAP_FSETID"
          "CAP_FOWNER" "CAP_KILL" "CAP_NET_RAW" "CAP_SETGID" "CAP_SETUID"
          "CAP_SETPCAP" "CAP_SYS_BOOT" "CAP_SYS_CHROOT" "CAP_SYS_MODULE"
          "CAP_SYS_NICE" "CAP_SYS_PACCT" "CAP_SYS_PTRACE" "CAP_SYS_RAWIO"
          "CAP_SYS_TIME" "CAP_SYS_TTY_CONFIG" "CAP_MKNOD" "CAP_AUDIT_WRITE"
          "CAP_IPC_LOCK" "CAP_LEASE" "CAP_LINUX_IMMUTABLE" "CAP_NET_BIND_SERVICE"
          "CAP_NET_ADMIN" "CAP_SYS_ADMIN" "CAP_SYSLOG" "CAP_WAKE_ALARM" "CAP_CHOWN"
        ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = "disconnected";
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "ptraceable";
        ProtectSystem = "full";
        RestrictAddressFamilies = [ "AF_UNIX" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };
in
{
  options.bautinix.nixos.hardware.storage.btrfs = with types; {
    enable = lib.mkEnableOption "support for btrfs devices";
    autoScrub = lib.mkEnableOption "btrfs autoScrub;";
    dedupe = lib.mkEnableOption "btrfs deduplication;";
    dedupeFilesystems = mkOpt (listOf str) [ ] "Unique btrfs filesystems to dedupe;";
    scrubMounts = mkOpt (listOf path) [ ] "Btrfs mount paths to scrub;";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btdu
      btrfs-assistant
      btrfs-snap
      compsize
      snapper
    ];

    services = {
      btrfs = {
        autoScrub = mkIf cfg.autoScrub {
          enable = true;
          fileSystems = mkIf (builtins.length cfg.scrubMounts > 0) cfg.scrubMounts;
          interval = "weekly";
        };
      };

      beesd = mkIf cfg.dedupe {
        filesystems = mkIf (builtins.length dedupeFilesystems > 0) dedupeFilesystemsAttrSets;
      };
    };

    systemd.services = lib.mkMerge [
      (lib.mkIf cfg.autoScrub (lib.listToAttrs (map hardenBtrfsScrubService cfg.scrubMounts)))
      {
        cpulimit-bees = {
          enable = cfg.dedupe;
          after = [ "sysinit.target" ];
          description = "CPU Limit Bees";
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "simple";
            ExecStart = "${getExe pkgs.cpulimit} -e bees -l 20";
            Restart = "always";
          };
        };
      }
    ];
  };
}
