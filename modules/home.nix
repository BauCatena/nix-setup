{ dotfiles ? "/home/bauti/dotfiles", pkgs, ... }:

let
  niriSettings = "${dotfiles}/nixosConfig/nixosConfig/modules/home/programs/graphical/wm/niri/settings";

  hmBackupScript = pkgs.writeShellScript "hm-backup" ''
    set -eu
    path="$1"
    ext="''${HOME_MANAGER_BACKUP_EXT:-hm-bak}"
    for old in "$path.$ext"*; do
      if [ -e "$old" ]; then
        rm -f "$old"
      fi
    done
    mv "$path" "$path.$ext"
  '';
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hm-bak";
  home-manager.overwriteBackup = true;
  home-manager.backupCommand = "${hmBackupScript}";
  home-manager.extraSpecialArgs = { inherit dotfiles; };
  home-manager.users.bauti = { config, pkgs, ... }: {
    # Put your new modular imports right here inside the Home Manager user block!
    imports = [
      ./home/programs
      ./home/services
      ./home/suites/temporly-all.nix
    ];

    home.stateVersion = "26.05";

    home.sessionPath = [
      "/run/wrappers/bin"
      "/run/current-system/sw/bin"
      "${dotfiles}/bin"
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    home.file.".local/bin" = {
      source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/bin";
      recursive = true;
    };

    services.swayidle = {
      enable = true;
      events = {
        before-sleep = "${niriSettings}/scripts/lock.sh";
        lock = "${niriSettings}/scripts/lock.sh";
      };
    };


    services.polkit-gnome.enable = true;
    services.gnome-keyring.enable = true;

    home.pointerCursor = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 22;
      gtk.enable = true;
      x11.enable = true;
    };
  };
}
