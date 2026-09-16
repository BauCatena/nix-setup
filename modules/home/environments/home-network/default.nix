{
  config,
  lib,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib) types;
  inherit (lib.bautinix) mkOpt;

  cfg = config.bautinix.environments.home-network;

  # Get server hostnames from OS config if available, otherwise use local setting
  serverHostname = osConfig.bautinix.environments.home-network.serverHostname or cfg.serverHostname;
  serverLocalHostname =
    osConfig.bautinix.environments.home-network.serverLocalHostname or cfg.serverLocalHostname;

  # The Tailscale (MagicDNS) aliases are only emitted when the daemon/app is
  # enabled. Basic aliases resolve over mDNS (.local) to avoid Tailscale SSH
  # re-auth on local connections.
  tailscaleEnabled = osConfig.bautinix.services.tailscale.enable or false;

  baseServer = {
    IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    IdentitiesOnly = true;
    User = config.bautinix.user.name;
  };

  # Unraid root inventory access. Persist the key in
  # /boot/config/ssh/root.pubkeys, then copy it to /root/.ssh/authorized_keys
  # and restart sshd when active root key auth needs to be refreshed.
  rootServer = {
    BatchMode = true;
    IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
    IdentitiesOnly = true;
    KbdInteractiveAuthentication = false;
    PasswordAuthentication = false;
    PreferredAuthentications = "publickey";
    User = "root";
  };
in
{
  options.bautinix.environments.home-network = with types; {
    enable = lib.mkEnableOption "home network environment";
    serverHostname = mkOpt str "tailb71378.ts.net" "Home server MagicDNS hostname";
    serverLocalHostname = mkOpt str "server.local" "Home server LAN (mDNS) hostname";
  };

  config = mkIf cfg.enable {


    # Run once from each client host that needs access:
    # ssh-copy-id -i ~/.ssh/id_ed25519.pub ${config.bautinix.user.name}@${serverLocalHostname}
    programs.ssh.settings = lib.mkMerge [
      {
        "austinserver austinserver.local server" = lib.mkDefault (
          baseServer // { HostName = serverLocalHostname; }
        );
        "austinserver-root" = lib.mkDefault (rootServer // { HostName = serverLocalHostname; });
      }
      (mkIf tailscaleEnabled {
        "austinserver-ts" = lib.mkDefault (baseServer // { HostName = serverHostname; });
        "austinserver-root-ts" = lib.mkDefault (rootServer // { HostName = serverHostname; });
      })
    ];
  };
}
