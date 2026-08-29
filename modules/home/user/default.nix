{
  config,
  inputs,
  lib,
  pkgs,
  username ? null,
  ...
}:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    getExe
    getExe'
    ;
  inherit (lib.bautinix) mkOpt enabled;

  cfg = config.bautinix.user;

  fastNixGcPackage =
    let
      package = lib.attrByPath [
        "fast-nix-gc"
        "packages"
        pkgs.stdenv.hostPlatform.system
        "default"
      ] null inputs;
    in
    if package == null then
      null
    else
      package.overrideAttrs (old: {
        checkFlags =
          (old.checkFlags or [ ])
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            "--skip"
            "gc_deletes_non_utf8_store_entry"
            "--skip"
            "gc_does_not_hang_on_tmp_fifo"
          ];
      });
  gcCommand = if fastNixGcPackage != null then "fast-nix-gc" else "nix-collect-garbage";

  home-directory =
    if cfg.name == null then
      null
    else if pkgs.stdenv.hostPlatform.isDarwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";

  getDir =
    dir: default:
    if config.xdg.userDirs.enable then
      lib.removePrefix "${config.home.homeDirectory}/" dir
    else
      default;
in
{
  options.bautinix.user = {
    enable = mkOpt types.bool true "Whether to configure the user account.";
    email = mkOpt types.str "bauti@example.com" "The email of the user.";
    fullName = mkOpt types.str "Bauti" "The full name of the user.";
    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
    icon =
      mkOpt (types.nullOr types.package) (pkgs.bautinix.user-icon or null)
        "The profile picture to use for the user.";
    name = mkOpt (types.nullOr types.str) username "The user account.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "bautinix.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "bautinix.user.home must be set";
        }
      ];

      home = {
        file =
          lib.optionalAttrs (!pkgs.stdenv.hostPlatform.isDarwin) {
            "${getDir config.xdg.userDirs.desktop "Desktop"}/.keep".text = "";
            "${getDir config.xdg.userDirs.documents "Documents"}/.keep".text = "";
            "${getDir config.xdg.userDirs.download "Downloads"}/.keep".text = "";
            "${getDir config.xdg.userDirs.music "Music"}/.keep".text = "";
            "${getDir config.xdg.userDirs.pictures "Pictures"}/.keep".text = "";
            "${getDir config.xdg.userDirs.videos "Videos"}/.keep".text = "";
          }
          // lib.optionalAttrs (cfg.icon != null) {
            ".face".source = cfg.icon;
            ".face.icon".source = cfg.icon;
            "${getDir config.xdg.userDirs.pictures "Pictures"}/${
              cfg.icon.fileName or (baseNameOf "${cfg.icon}")
              }".source = cfg.icon;
          };

        homeDirectory = mkIf (cfg.home != null) (mkDefault cfg.home);

        preferXdgDirectories = true;

        packages = lib.optional (fastNixGcPackage != null) fastNixGcPackage;

        shellAliases = {
          cleanup =
            if pkgs.stdenv.hostPlatform.isDarwin then
              ''
                sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
                sudo ${gcCommand} --delete-older-than 3d && ${gcCommand} -d
                sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
              ''
            else
              ''
                sudo ${gcCommand} --delete-older-than 3d && ${gcCommand} -d
              '';
          bloat = "nix path-info -Sh /run/current-system";
          curgen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
          gc-check = "nix-store --gc --print-roots | egrep -v \"^(/nix/var|/run/\\w+-system|\\{memory|/proc)\"";
          repair =
            if pkgs.stdenv.hostPlatform.isDarwin then
              ''
                sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
                nix-store --verify --check-contents --repair
                sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
              ''
            else
              ''
                nix-store --verify --check-contents --repair
              '';
          nixnuke = ''
            sudo pkill -9 -f "nix-(daemon|store|build)" || true
            for pid in $(ps -axo pid,user | ${getExe pkgs.gnugrep} -E '[_]?nixbld[0-9]+' | ${getExe pkgs.gawk} '{print $1}'); do
              sudo kill -9 "$pid" 2>/dev/null || true
            done
            ${
              if pkgs.stdenv.hostPlatform.isDarwin then
                "sudo launchctl kickstart -k system/org.nixos.nix-daemon"
              else
                "sudo systemctl restart nix-daemon.service"
            }
          '';
          flake = "nix flake";
          nix = "nix -vL";
          gsed = "${getExe pkgs.gnused}";
          hmvar-reload = ''unset __HM_SESS_VARS_SOURCED; source "/etc/profiles/per-user/${config.bautinix.user.name}/etc/profile.d/hm-session-vars.sh"'';

          rcp = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1";
          rmv = "${getExe pkgs.rsync} -rahP --mkpath --modify-window=1 --remove-sent-files";
          tarnow = "${getExe pkgs.gnutar} -acf ";
          untar = "${getExe pkgs.gnutar} -zxvf ";
          wget = "${getExe pkgs.wget} -c ";
          remove-empty = "${getExe' pkgs.findutils "find"} . -type d -empty -delete";
          print-empty = "${getExe' pkgs.findutils "find"} . -type d -empty -print";
          dfh = "${getExe' pkgs.coreutils "df"} -h";
          duh = "${getExe' pkgs.coreutils "du"} -h";
          usage = "${getExe' pkgs.coreutils "du"} -ah -d1 | sort -rn 2>/dev/null";

          home = "cd ~";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";

          dir = "${getExe' pkgs.coreutils "dir"} --color=auto";
          egrep = "${getExe' pkgs.gnugrep "egrep"} --color=auto";
          fgrep = "${getExe' pkgs.gnugrep "fgrep"} --color=auto";
          grep = "${getExe pkgs.gnugrep} --color=auto";
          vdir = "${getExe' pkgs.coreutils "vdir"} --color=auto";

          clear = "clear && ${getExe config.programs.fastfetch.package}";
          clr = "clear";
          pls = "sudo";
          psg = "${getExe pkgs.ps} aux | grep";
          myip = "${getExe pkgs.curl} ifconfig.me";

          genpass = "${getExe pkgs.openssl} rand -base64 20";
          sha = "shasum -a 256";
        };

        username = mkDefault cfg.name;
      };

      programs.home-manager = enabled;
    }
  ]);
}
