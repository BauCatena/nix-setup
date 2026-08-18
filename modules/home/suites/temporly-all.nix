{ ... }:
{
  bautinix = {
    home = {
      programs = {
        terminal = {
          tools = {
            yazi.enable = true;
            btop.enable = true;
            cava.enable = true;
            fastfetch.enable = true;
            himalaya.enable = true;
            jq.enable = true;
            ncdu.enable = true;
            ripgrep.enable = true;
            ssh.enable = true;
            tree.enable = true;
            git.enable = true;
            tmux.enable = true;
            nodejs.enable = true;
            python3.enable = true;
            gcc.enable = true;
            cmatrix.enable = true;
            atuin.enable = true;
            libsecret.enable = true;
          };
          editors = {
            neovim.enable = true;
            nano.enable = true;
          };
          emulators = {
            foot.enable = true;
          };
            shells = {
            zsh.enable = true;
          };
        };
        graphical = {
          addons = {
              libinput-gestures.enable = true;
              grim.enable = true;
              slurp.enable = true;
              wl-clipboard.enable = true;
              cliphist.enable = true;
              playerctl.enable = true;
              libnotify.enable = true;
              xwayland-satellite.enable = true;
            };
          apps = {
            libreoffice.enable = true;
            obsidian.enable = true;
            vesktop.enable = true;
            spotify.enable = true;
          };
          bars = { quickshell.enable = true; };
          browsers = { firefox.enable = true; };
          launchers = { tofi.enable = true; };
          screenlockers = { swaylock-effects.enable = true; };
          wms = { niri.enable = true; };
        };
      };
      services = {
        awww.enable = true;
      };
    };
  };
}
