{
  config,
  lib,
  ...
}:
let
  cfg = config.bautinix.theme.tokyonight;
  tokyonight = import ./colors.nix;
  colors = tokyonight.getVariant (cfg.variant or "night");

  palette = {
    dirBg = colors.blue;
    dirFg = colors.bg;
    gitBg = colors.bg_highlight;
    gitFg = colors.fg;
    modulesBg = colors.bg_dark;
    modulesFg = colors.fg;
    timeBg = colors.terminal_black;
    timeFg = colors.fg;
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = "$directory[](fg:${palette.dirBg} bg:${palette.gitBg})$git_branch$git_status[](fg:${palette.gitBg} bg:${palette.modulesBg})$nodejs$bun$rust$golang$php[](fg:${palette.modulesBg} bg:${palette.timeBg})$time[ ](fg:${palette.timeBg})\n$character";

        directory = {
          style = "fg:${palette.dirFg} bg:${palette.dirBg}";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };

        git_branch = {
          symbol = "";
          style = "bg:${palette.gitBg}";
          format = "[[ $symbol $branch ](fg:${palette.gitFg} bg:${palette.gitBg})]($style)";
        };

        git_status = {
          style = "bg:${palette.gitBg}";
          format = "[[($all_status$ahead_behind )](fg:${palette.gitFg} bg:${palette.gitBg})]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:${palette.modulesBg}";
          format = "[[ $symbol ($version) ](fg:${palette.modulesFg} bg:${palette.modulesBg})]($style)";
        };

        bun = {
          symbol = "";
          style = "bg:${palette.modulesBg}";
          format = "[[ $symbol ($version) ](fg:${palette.modulesFg} bg:${palette.modulesBg})]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:${palette.modulesBg}";
          format = "[[ $symbol ($version) ](fg:${palette.modulesFg} bg:${palette.modulesBg})]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:${palette.modulesBg}";
          format = "[[ $symbol ($version) ](fg:${palette.modulesFg} bg:${palette.modulesBg})]($style)";
        };

        php = {
          symbol = "";
          style = "bg:${palette.modulesBg}";
          format = "[[ $symbol ($version) ](fg:${palette.modulesFg} bg:${palette.modulesBg})]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "fg:${palette.timeFg} bg:${palette.timeBg}";
        };
      };
    };
  };
}
