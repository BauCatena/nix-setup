{
  config,
  lib,
  ...
}:
let
  mkOpt = type: default: description:
    lib.mkOption { inherit type default description; };

  cfg = config.bautinix.programs.terminal.tools.ssh;

  # Get local user info
  user = config.users.users.${config.bautinix.user.name};
  user-id = toString user.uid;

  # Load companion hosts file
  hosts = import ./hosts.nix;

  # Tailscale MagicDNS configuration
  magicDnsSuffix = "taild8431e.ts.net"; # Change this to your actual Tailnet suffix if using Tailscale
  tailscaleEnabled = config.services.tailscale.enable or false;

  # Filter out the current machine from the generated SSH list
  other-hosts = lib.filterAttrs (name: _: name != config.networking.hostName) hosts;

  other-hosts-config = lib.concatMapStringsSep "\n" (
    name:
    let
      remote = other-hosts.${name};
      remote-user-name = remote.username;
      
      # Standard Linux UID
      remote-user-id = "1000";

      forward-gpg =
        lib.optionalString (config.programs.gnupg.agent.enable && (remote.gpgAgent or false))
          "  RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent /run/user/${user-id}/gnupg/S.gpg-agent.extra\n  RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent.ssh /run/user/${user-id}/gnupg/S.gpg-agent.ssh";
      
      port-expr = "  Port ${toString cfg.port}";

      mkHostBlock =
        aliasName: hostname:
        lib.concatStringsSep "\n" (
          lib.filter (x: x != "") [
            "Host ${aliasName}"
            "  Hostname ${hostname}"
            "  User ${remote-user-name}"
            "  ForwardAgent yes"
            "  ConnectTimeout 10"
            port-expr
            forward-gpg
          ]
        );
    in
    lib.concatStringsSep "\n" (
      [ (mkHostBlock name remote.hostname) ]
      ++ lib.optional tailscaleEnabled (mkHostBlock "${name}-ts" "${name}.${magicDnsSuffix}")
    )
  ) (builtins.attrNames other-hosts);
in
{
  options.bautinix.programs.terminal.tools.ssh = {
    enable = lib.mkEnableOption "ssh support";
    extraConfig = mkOpt lib.types.str "" "Extra configuration to apply.";
    port = mkOpt lib.types.port 2222 "The port to listen on.";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      extraConfig = ''
        Host *
          AddKeysToAgent yes
          ForwardAgent no
          ServerAliveInterval 30
          ServerAliveCountMax 2
          StreamLocalBindUnlink yes
          ConnectTimeout 5

        ${other-hosts-config}${
          lib.optionalString (cfg.extraConfig != "") ''

            ${cfg.extraConfig}''
        }
      '';

      knownHosts = lib.mapAttrs (_: lib.mkForce) (
        {
          github-ed25519 = {
            hostNames = [ "github.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };
          gitlab-ed25519 = {
            hostNames = [ "gitlab.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
          };
        }
        // lib.mapAttrs (name: host: {
          hostNames = [ host.hostname ] ++ lib.optional tailscaleEnabled "${name}.${magicDnsSuffix}";
          inherit (host) publicKey;
        }) (lib.filterAttrs (_: host: host ? publicKey) hosts)
      );
    };

    bautinix.home.extraOptions = {
      home = {
        file.".ssh/controlmasters/.keep".text = "";

        shellAliases = builtins.listToAttrs (
          map (system: {
            name = "ssh-${system}";
            value = ''ssh ${system} -t "tmux new-session -A -s main"'';
          }) (builtins.attrNames other-hosts)
        );
      };
    };
  };
}
