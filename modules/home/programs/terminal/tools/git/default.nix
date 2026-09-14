{
  config,
  lib,
  pkgs,
  getPkgsUnstable,
  ...
}:
let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    getExe'
    ;
  inherit (lib.bautinix) mkOpt enabled;
  inherit (config.bautinix) user;

  cfg = config.bautinix.programs.terminal.tools.git;

  sshHosts = import (lib.getFile "modules/nixos/programs/terminal/tools/ssh/hosts.nix");

  hasGithubAccessToken = lib.hasAttrByPath [ "sops" "secrets" "github/access-token" ] config;
posixTokenExports = lib.optionalString (config.bautinix.services.sops.enable or false && hasGithubAccessToken) ''
  if [ -f ${config.sops.secrets."github/access-token".path} ]; then
    GITHUB_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
    export GITHUB_TOKEN
    GH_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
    export GH_TOKEN
    GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${config.sops.secrets."github/access-token".path})"
    export GITHUB_PERSONAL_ACCESS_TOKEN
  fi
'';
  fishTokenExports = lib.optionalString (config.bautinix.services.sops.enable or false) /* fish */ ''
    if ${lib.boolToString hasGithubAccessToken}; and test -f ${
      config.sops.secrets."github/access-token".path
    }
      set -gx GITHUB_TOKEN (cat ${config.sops.secrets."github/access-token".path})
      set -gx GH_TOKEN (cat ${config.sops.secrets."github/access-token".path})
      # For github-mcp-server
      set -gx GITHUB_PERSONAL_ACCESS_TOKEN (cat ${config.sops.secrets."github/access-token".path})
    end
  '';
in
{
  options.bautinix.programs.terminal.tools.git = {
    enable = mkEnableOption "Git";
    includes = mkOpt (types.listOf types.attrs) [ ] "Git includeIf paths and conditions.";
    signByDefault = mkOpt types.bool true "Whether to sign commits by default.";
    signingKey =
      mkOpt types.str "${config.home.homeDirectory}/.ssh/id_ed25519"
        "The key ID to sign commits with.";
    userName = mkOpt types.str user.fullName "The name to configure git with.";
    userEmail = mkOpt types.str user.email "The email to configure git with.";
    wslAgentBridge = lib.mkEnableOption "the wsl agent bridge";
    wslGitCredentialManagerPath =
      mkOpt types.str "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
        "The windows git credential manager path.";
    _1password = lib.mkEnableOption "1Password integration";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        bfg-repo-cleaner
        git-absorb
        git-crypt
        git-filter-repo
        git-lfs
        gitflow
        gitleaks
        gitlint
        tig
      ];
      # git-surgeon comes from the llm-agents input; keep that input out of
      # hosts that do not opt into AI tooling.
    programs = {
      delta = {
        enable = true;
        enableGitIntegration = true;

        options = {
          dark = true;
          line-numbers = true;
          navigate = true;
          side-by-side = true;
        };
      };

      difftastic = {
        enable = !config.programs.kitty.enable && !config.programs.delta.enable;

        git = {
          enable = true;
        };

        options = {
          background = "dark";
          display = "inline";
        };
      };

      git = {
        enable = true;
        package = pkgs.gitFull;


        maintenance.enable = true;

        # Git configuration
        # See: https://git-scm.com/docs/git-config
        settings = {

          branch.sort = "-committerdate";

          credential = {
            helper =
              lib.optionalString cfg.wslAgentBridge cfg.wslGitCredentialManagerPath
              + lib.optionalString (!cfg.wslAgentBridge && pkgs.stdenv.hostPlatform.isLinux) (
                getExe' config.programs.git.package "git-credential-libsecret"
              )
              + lib.optionalString (!cfg.wslAgentBridge && pkgs.stdenv.hostPlatform.isDarwin) (
                getExe' config.programs.git.package "git-credential-osxkeychain"
              );

            useHttpPath = true;
          };

          fetch = {
            prune = true;
          };

          # TODO: verify still works
          "gpg \"ssh\"".program = mkIf cfg._1password (
            let
              pkgsUnstable = getPkgsUnstable pkgs.stdenv.hostPlatform.system { inherit (pkgs) config; };
            in
            lib.optionalString pkgs.stdenv.hostPlatform.isLinux (
              getExe' pkgsUnstable._1password-gui "op-ssh-sign"
            )
            + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin "${pkgsUnstable._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          );

          init = {
            defaultBranch = "main";
          };

          lfs = enabled;

          pull = {
            rebase = true;
          };

          push = {
            autoSetupRemote = true;
            default = "current";
          };

          rerere = {
            enabled = true;
          };

          rebase = {
            autoStash = true;
          };

          safe = {
            directory = [
              "${config.home.homeDirectory}/bautinix/"
              "/etc/nixos"
              "/etc/nix-darwin"
            ];
          };

          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
        };

        signing = {
          key = cfg.signingKey;
          format = "ssh";
          inherit (cfg) signByDefault;
        };
      };

      mergiraf = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
      };

      bash.initExtra = posixTokenExports;
      fish.shellInit = fishTokenExports;
      zsh.initContent = posixTokenExports;
    };

    #    sops.secrets = lib.mkIf (config.bautinix.services.sops.enable or false) {
    #  "github/access-token" = {
    #    sopsFile = lib.getFile "secrets/bauti/default.yaml";
    #    path = "${config.home.homeDirectory}/.config/gh/access-token";
    #  };
    #};
  };
}
