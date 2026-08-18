{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib)
    types
    mkIf
    getExe'
    ;
  mkOpt = type: default: description: lib.mkOption {
    inherit type default description;
  };
  cfg = config.bautinix.nixos.security.gpg;

  gpgAgentConf = ''
    enable-ssh-support
    default-cache-ttl 60
    max-cache-ttl 120
    pinentry-program ${getExe' pkgs.pinentry-gnome3 "pinentry-gnome3"}
  '';
in
{
  options.bautinix.nixos.security.gpg = with types; {
    enable = lib.mkEnableOption "GPG";
    agentTimeout = mkOpt int 5 "The amount of time to wait before continuing with shell init.";
    enableSSHSupport = lib.mkEnableOption "SSH support for GPG";
  };
    options.bautinix.home = {
      file = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Custom home files mapping.";
      };
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cryptsetup
      gnupg
      paperkey
      pinentry-qt
    ];

    bautinix = {
      home.file = {
        ".gnupg/gpg-agent.conf".text = gpgAgentConf;
      };
    };

    programs = {
      gnupg.agent = {
        enable = true;
        inherit (cfg) enableSSHSupport;
        enableExtraSocket = true;
        pinentryPackage = pkgs.pinentry-gnome3;
      };
    };

    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
    };
  };
}
