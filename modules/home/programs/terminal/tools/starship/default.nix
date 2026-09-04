{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.starship;
in
{
  options.bautinix.programs.terminal.tools.starship.enable =
    lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = lib.mkDefault {
        format = " $username $hostname [] $directory[](fg:#769ff0 bg:#394260)$git_branch$git_status[](fg:#394260 bg:#212736)$nodejs$bun$rust$golang$php[](fg:#212736 bg:#1d2230)$time[ ](fg:#1d2230)\n$character";

        directory = {
          style = "fg:#e3e5e5 bg:#769ff0";
          format = "[ $path ]($style)";
          truncation_length = 4;
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };
        username = {
          format = "[$user]($style)";
        };

        hostname = {
          format = "@[$hostname]($style)";
        };

        git_branch = {
          symbol = "";
          style = "bg:#394260";
          format = "[[ $symbol $branch ](fg:#769ff0 bg:#394260)]($style)";
        };

        git_status = {
          style = "bg:#394260";
          format = "[[($all_status$ahead_behind )](fg:#769ff0 bg:#394260)]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        bun = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        php = {
          symbol = "";
          style = "bg:#212736";
          format = "[[ $symbol ($version) ](fg:#769ff0 bg:#212736)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:#1d2230";
        };
      };
    };
  };
}
