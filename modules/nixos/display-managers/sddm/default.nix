{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe' stringAfter;

  enabled = { enable = true; };

  cfg = config.bautinix.nixos.display-managers.sddm;

  userName = config.bautinix.user.name;


  # SDDM only prefills the username from state written after a successful
  # login; seed it so the very first login is already populated.
  seedStateFile = pkgs.writeText "sddm-state.conf" ''
    [Last]
    User=${userName}
  '';
in
{
  options.bautinix.nixos.display-managers.sddm = {
    enable = lib.mkEnableOption "sddm";
  };

  config = mkIf cfg.enable {
    bautinix.home.file =
      let
        inherit (config.home-manager.users.${userName}.bautinix.user) icon;
      in
      lib.mkIf (icon != null) {
        "sddm/faces/.${userName}".source = icon;
      };

    services = {
      displayManager = {
        sddm = {
          inherit (cfg) enable;
          package = lib.mkDefault pkgs.kdePackages.sddm;
          wayland = enabled;
        };
      };
    };

    # C = copy only when the destination is missing
    systemd.tmpfiles.rules = [
      "C /var/lib/sddm/state.conf 0600 sddm sddm - ${seedStateFile}"
    ];

    system.activationScripts.postInstallSddm = stringAfter [ "users" ] /* Bash */ ''
      echo "Setting sddm permissions for user icon"
      ${getExe' pkgs.acl "setfacl"} -m u:sddm:x /home/${userName}
    '';
  };
}
