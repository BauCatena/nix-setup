{
  config,
  lib,

  ...
}:
let
   mkOpt = type: default: description: lib.mkOption {
    inherit type default description;
  };
  cfg = config.bautinix.nixos.security.sops;
in
{
  options.bautinix.nixos.security.sops = {
    enable = lib.mkEnableOption "sops";
    defaultSopsFile = mkOpt lib.types.path null "Default sops file.";
    sshKeyPaths = mkOpt (with lib.types; listOf path) [
      "/etc/ssh/ssh_host_ed25519_key"
    ] "SSH Key paths to use.";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      inherit (cfg) defaultSopsFile;

      age = {
        inherit (cfg) sshKeyPaths;

        keyFile = "${config.users.users.${config.bautinix.nixos.user.name}.home}/.config/sops/age/keys.txt";
      };
    };
  };
}
