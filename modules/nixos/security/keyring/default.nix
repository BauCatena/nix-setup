{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.security.keyring;
in
{
  options.bautinix.security.keyring = {
    enable = lib.mkEnableOption "gnome keyring";
  };

  config = mkIf cfg.enable {
    # NOTE: Also enables services.gnome.gcr-ssh-agent apparently
    services.gnome.gnome-keyring.enable = true;
  };
}
