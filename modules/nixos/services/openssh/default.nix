{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkDefault
    mkIf
    mkOption
    ;

  cfg = config.bautinix.nixos.services.openssh;

  # Local helper for cleaner options (replaces lib.bautinix.nixos.mkOpt)
  mkOpt = type: default: description: mkOption {
    inherit type default description;
  };
in
{
  options.bautinix.nixos.services.openssh = with types; {
    enable = lib.mkEnableOption "OpenSSH support";
    startAgent = lib.mkEnableOption "starting openssh agent";
    
    authorizedKeys = mkOpt (listOf str) [
      # PASTE YOUR PUBLIC SSH KEY HERE DIRECTLY FOR NOW
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPb3NH7aQun+KugSvQcRjbqjxmlb0dcTIuSaaftR+GI5 bauti-pc"
    ] "The public keys to apply.";

    extraConfig = mkOpt str "" "Extra configuration to apply.";
    port = mkOpt port 2222 "The port to listen on (in addition to 22).";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;

      hostKeys = mkDefault [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      openFirewall = true;
      ports = [
        cfg.port
      ];

      settings = {
        AuthenticationMethods = "publickey";
        ChallengeResponseAuthentication = "no";
        PasswordAuthentication = false;
        PermitRootLogin = "no"; # Locked down securely for everyday use
        PubkeyAuthentication = "yes";
        StreamLocalBindUnlink = "yes";
        UseDns = false;
        UsePAM = true;
        X11Forwarding = false;

        # Hardened KexAlgorithms & Macs recommended by `ssh-audit`
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group-exchange-sha256"
          "sntrup761x25519-sha512@openssh.com"
        ];

        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
        ];
      };
    };

    programs.ssh = {
      inherit (cfg) extraConfig startAgent;
    };

    # Automatically feed your authorized keys into your main user account
    users.users.bauti = {
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
  };
}
