{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs) tokyonight;
  inherit (lib) mkIf mkForce;

  cfg = config.bautinix.theme.tokyonight;
  variant = if cfg.variant == "storm" then "night" else cfg.variant;
  colors = (import ./colors.nix).getVariant cfg.variant;
  # Codex discovers custom syntax themes as {CODEX_HOME}/themes/{name}.tmTheme,
  # matching where home-manager's codex module writes config.toml.
  codexConfigDir =
    if config.home.preferXdgDirectories then
      "${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex"
    else
      ".codex";
in
{
  config = mkIf cfg.enable {
    programs = {
      #          ╭──────────────────────────────────────────────────────────╮
      #          │   Available application configurations from tokyonight   │
      #          │                         extras:                          │
      #          │   aerc, aider, alacritty, btop, delta, discord, dunst,   │
      #          │              eza, fish, fish_themes, foot,               │
      #          │   fuzzel, fzf, ghostty, gitui, gnome_terminal, helix,    │
      #          │           ish, iterm, kitty, konsole, lazygit,           │
      #          │    lua, opencode, prism, process_compose, qterminal,     │
      #          │           slack, spotify_player, st, sublime,            │
      #          │    tailwindv4, terminator, termux, tilix, tmux, vim,     │
      #          │  vimium, vivaldi, wezterm, windows_terminal, xfceterm,   │
      #          │            xresources, yazi, zathura, zellij             │
      #          ╰──────────────────────────────────────────────────────────╯

      alacritty.settings.general.import = [
        "${tokyonight}/extras/alacritty/tokyonight_${variant}.toml"
      ];

      bat.config.theme = "tokyonight_${variant}";

      btop.settings.color_theme = mkForce "tokyonight_${variant}";

      delta.options = mkIf config.programs.delta.enable (
        let
          deltaConfig = builtins.readFile "${tokyonight}/extras/delta/tokyonight_${variant}.gitconfig";
          lines = lib.splitString "\n" deltaConfig;
          # Parse the gitconfig into an attrset
          parseLine =
            line:
            let
              trimmed = lib.trim line;
              # Skip empty lines, comments, and [delta] section header
              isValid = trimmed != "" && !(lib.hasPrefix "#" trimmed) && !(lib.hasPrefix "[" trimmed);
            in
            if isValid then
              let
                parts = lib.splitString "=" trimmed;
                key = lib.trim (builtins.head parts);
                value = lib.trim (lib.concatStringsSep "=" (lib.tail parts));
              in
              lib.nameValuePair key value
            else
              null;
          parsed = builtins.filter (x: x != null) (map parseLine lines);
        in
        builtins.listToAttrs parsed
      );

      fish.interactiveShellInit = ''
        source ${tokyonight}/extras/fish/tokyonight_${variant}.fish
      '';

      foot.settings.colors = /* toml */ ''
        ${builtins.readFile "${tokyonight}/extras/foot/tokyonight_${variant}.ini"}
      '';

      fzf.defaultOptions = [
        "--color=fg:${colors.fg}"
        "--color=bg:${colors.bg}"
        "--color=hl:${colors.blue}"
        "--color=fg+:${colors.fg}"
        "--color=bg+:${colors.bg_highlight}"
        "--color=hl+:${colors.blue}"
        "--color=info:${colors.cyan}"
        "--color=prompt:${colors.blue}"
        "--color=pointer:${colors.cyan}"
        "--color=marker:${colors.cyan}"
        "--color=spinner:${colors.cyan}"
        "--color=header:${colors.blue}"
      ];


      kitty.extraConfig = ''
        include ${tokyonight}/extras/kitty/tokyonight_${variant}.conf
      '';

      lazygit.settings.gui.theme = {
        lightTheme = cfg.variant == "day";
        activeBorderColor = [
          "blue"
          "bold"
        ];
        inactiveBorderColor = [ "white" ];
        selectedLineBgColor = [ "blue" ];
      };

     satty.settings = mkIf config.bautinix.programs.graphical.addons.satty.enable {
        color-palette = {
          palette = [
            colors.red
            colors.orange
            colors.yellow
            colors.green
            colors.teal
            colors.blue
            colors.magenta
            colors.purple
          ];

          custom = [
            colors.red
            colors.red1
            colors.orange
            colors.yellow
            colors.green
            colors.green1
            colors.green2
            colors.teal
            colors.cyan
            colors.blue
            colors.blue1
            colors.blue2
            colors.magenta
            colors.purple
          ];
        };
      };

      tmux.extraConfig = ''
        source-file ${tokyonight}/extras/tmux/tokyonight_${variant}.tmux

        set -g status-left-length 24
        set -g status-right-length 40
        set -g status-left "#[fg=${colors.fg},bg=default,bold] #S #[fg=${colors.bg_dark},bg=default,nobold]"
        set -g status-right "#[fg=${colors.yellow},bg=${colors.bg_dark}]#{prefix_highlight}#[fg=${colors.comment},bg=${colors.bg_dark}] #h "

        set -g window-style "bg=${colors.bg}"
        set -g window-active-style "bg=${colors.bg}"
        set -g popup-style "fg=${colors.fg},bg=${colors.bg_dark}"
        set -g popup-border-style "fg=${colors.blue},bg=${colors.bg_dark}"

        setw -g window-status-format "#[fg=${colors.bg_dark},bg=${colors.bg_highlight},nobold,nounderscore,noitalics]#[fg=${colors.fg_dark},bg=${colors.bg_highlight}] #I  #W #[fg=${colors.bg_highlight},bg=${colors.bg_dark},nobold,nounderscore,noitalics]"
        setw -g window-status-current-format "#[fg=${colors.bg_dark},bg=${colors.blue},nobold,nounderscore,noitalics]#[fg=${colors.bg},bg=${colors.blue},bold] #I  #W #[fg=${colors.blue},bg=${colors.bg_dark},nobold,nounderscore,noitalics]"
        setw -g window-status-activity-style "fg=${colors.yellow},bg=${colors.bg_highlight},bold"
        setw -g window-status-bell-style "fg=${colors.bg},bg=${colors.orange},bold"
      '';

      vesktop.vencord = mkIf config.bautinix.programs.graphical.apps.vesktop.enable {
        settings.enabledThemes = [ "tokyonight.css" ];
        themes.tokyonight = "${tokyonight}/extras/discord/tokyonight_${cfg.variant}.css";
      };

      wezterm.extraConfig = /* Lua */ ''
        function scheme_for_appearance(appearance)
          if appearance:find "Dark" then
            return "tokyonight_night"
          else
            return "tokyonight_day"
          end
        end
      '';

      zellij.settings.theme = "tokyonight_${variant}";
    };

    xdg.configFile = lib.mkMerge [
      (mkIf config.programs.bat.enable {
        "bat/themes/tokyonight_${variant}.tmTheme".source =
          "${tokyonight}/extras/sublime/tokyonight_${variant}.tmTheme";
      })

      (mkIf config.programs.btop.enable {
        "btop/themes/tokyonight_${variant}.theme".source =
          "${tokyonight}/extras/btop/tokyonight_${variant}.theme";
      })

      (mkIf config.services.dunst.enable {
        "dunst/tokyonight_${variant}.conf".source = "${tokyonight}/extras/dunst/tokyonight_${variant}.conf";
      })

      (mkIf config.programs.eza.enable {
        "eza/theme.yml".source = mkForce "${tokyonight}/extras/eza/tokyonight_${variant}.yml";
      })

      (mkIf config.programs.fuzzel.enable {
        "fuzzel/tokyonight.ini".source = "${tokyonight}/extras/fuzzel/tokyonight_${variant}.ini";
      })

      (mkIf config.programs.yazi.enable {
        "yazi/theme.toml".source = mkForce (
          pkgs.runCommand "tokyonight-yazi-theme.toml" { } ''
            sed \
              -e 's/name =/url =/g' \
              -e '/^\[mgr\]/,/^\[/ { /^hovered[[:space:]]*=/d; /^preview_hovered[[:space:]]*=/d; }' \
              -e '/^\[which\]$/a border = { fg = "${colors.blue}" }' \
              -e '/^\[confirm\]/,/^\[/ s/^content[[:space:]]*=/body =/' \
              -e '/^\[help\]$/a border = { fg = "${colors.blue}" }' \
              -e '/^\[help\]/,/^\[/ s/^on[[:space:]]*=/chord =/' \
              -e '/^\[help\]/,/^\[/ s/^run[[:space:]]*=/action =/' \
              -e '/^\[help\]/,/^\[/ { /^desc[[:space:]]*=/d; /^footer[[:space:]]*=/d; }' \
              -e '/^\[filetype\]/,$ s|mime = "|mime = "**/|' \
              ${tokyonight}/extras/yazi/tokyonight_${variant}.toml > theme.tmp

            sed '/^[[:space:]]*# Fallback$/i\
            \t{ mime = "vfs/{absent,stale}", fg = "${colors.comment}" },' theme.tmp > "$out"

            printf '\n[indicator]\nparent = { bg = "${colors.bg_highlight}" }\ncurrent = { bg = "${colors.bg_highlight}" }\npreview = { bg = "${colors.bg_highlight}" }\n' >> "$out"

            grep -Eq '^chord[[:space:]]*=' "$out"
            grep -Eq '^action[[:space:]]*=' "$out"
            grep -Eq '^body[[:space:]]*=' "$out"
            grep -Fq 'mime = "**/image/*"' "$out"
            grep -Fq 'mime = "vfs/{absent,stale}"' "$out"
            grep -Fxq '[indicator]' "$out"
          ''
        );
      })

      (mkIf config.programs.cava.enable {
        "cava/config".text = ''
          [color]
          gradient = 1
          gradient_count = 6
          gradient_color_1 = '${colors.blue}'
          gradient_color_2 = '${colors.cyan}'
          gradient_color_3 = '${colors.green}'
          gradient_color_4 = '${colors.yellow}'
          gradient_color_5 = '${colors.orange}'
          gradient_color_6 = '${colors.red}'
        '';
      })

      (mkIf config.programs.fish.enable {
        "fish/themes/tokyonight_${variant}.theme".source =
          "${tokyonight}/extras/fish_themes/tokyonight_${variant}.theme";
      })
    ];
    home.file = lib.mkMerge [
      ({
        ".Xresources.d/tokyonight".source =
          "${tokyonight}/extras/xresources/tokyonight_${variant}.Xresources";
      })

      ({
        "${codexConfigDir}/themes/tokyonight_${variant}.tmTheme".source =
          "${tokyonight}/extras/sublime/tokyonight_${variant}.tmTheme";
      })
    ];
  };
}
