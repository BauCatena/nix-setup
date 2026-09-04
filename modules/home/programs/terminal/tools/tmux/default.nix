{ config, lib, pkgs, osConfig ? { }, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.tmux;
  seshCfg = config.khanelinix.programs.terminal.tools.sesh;
  userShell = lib.attrByPath [ "users" "users" config.khanelinix.user.name "shell" ] (lib.attrByPath [
    "home"
    "sessionVariables"
    "SHELL"
  ] "" config) osConfig;
in
{
  options.bautinix.programs.terminal.tools.tmux.enable =
    lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];

    programs.tmux = {
 
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      clock24 = false;
      escapeTime = 0;
      historyLimit = 50000;
      keyMode = "vi";
      mouse = true;
      plugins = [
        {
          plugin = pkgs.tmuxPlugins.tmux-floax;
          extraConfig = /* Bash */ ''
            set -g @floax-bind 'g'
          '';
        }
        pkgs.tmuxPlugins.prefix-highlight
        pkgs.tmuxPlugins.resurrect
        {
          plugin = pkgs.tmuxPlugins.tmux-fzf;
          extraConfig = /* Bash */ ''
            set-environment -g TMUX_FZF_LAUNCH_KEY "G"
            set-environment -g TMUX_FZF_OPTIONS "-p -w 70% -h 60% -m"
            set-environment -g TMUX_FZF_ORDER "session|window|pane|keybinding"
            set-environment -g TMUX_FZF_PREVIEW 0
            set-environment -g TMUX_FZF_SESSION_FORMAT "#{session_name}#{?session_attached, [attached],}"
            set-environment -g TMUX_FZF_WINDOW_FORMAT "[#{session_name}] #I:#W  #{pane_current_command}"
            set-environment -g TMUX_FZF_PANE_FORMAT "[#{session_name}:#{window_name}] #{pane_current_command}  #{pane_current_path}"
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          extraConfig = /* Bash */ ''
            set -g @continuum-restore 'off'
          '';
        }
      ];
      prefix = "C-a";
      secureSocket = true;
      sensibleOnTop = false;
      terminal = "xterm-256color";


      extraConfig = /* Bash */ ''
        # Key bindings overrides
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi Escape send-keys -X cancel
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        bind '-' split-window -v -c '#{pane_current_path}'
        bind '"' split-window -v  -c '#{pane_current_path}'
        bind '|' split-window -h -c '#{pane_current_path}'
        bind '%' split-window -h -c '#{pane_current_path}'

        bind c new-window -c '#{pane_current_path}'
        bind n next-window
        bind p previous-window

        # Keep a prefix clear-screen shortcut available.
        bind C-l send-keys C-l
        bind-key T display-popup -E -w 80% -h 80% -d '#{pane_current_path}'
        bind-key R respawn-pane -k
        bind r source-file ~/.config/tmux/tmux.conf \; display-message 'tmux config reloaded'
        bind-key x kill-pane
      '';
    };
  };
}
