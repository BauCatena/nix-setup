{
  config,
  lib,
  ...
}:
let
  cfg = config.bautinix.theme.nord;
  nord = import ./colors.nix;
in
{
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = lib.mkForce {
        format = "$username$hostname[](bg:${nord.palette.nord9.hex} fg:${nord.palette.nord10.hex})$directory[](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord3.hex})$git_branch$git_status[](fg:${nord.palette.nord3.hex} bg:${nord.palette.nord2.hex})$nodejs$bun$rust$golang$php[](fg:${nord.palette.nord2.hex} bg:${nord.palette.nord1.hex})$time[ ](fg:${nord.palette.nord1.hex})\n$character";

        directory = {
          style = "fg:${nord.palette.nord4.hex} bg:${nord.palette.nord9.hex}";
          format = "[  $path  ]($style)";
          truncation_length = 4;
          truncation_symbol = "…/";
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
          };
        };

        hostname = {
          ssh_only = false;
          disabled = false;
          style = "bg:${nord.palette.nord10.hex} fg:${nord.palette.nord4.hex}";
          format = "[@$hostname  ]($style)";
        };

        username = {
          show_always = true;
          disabled = false;
          style_user = "bg:${nord.palette.nord10.hex} fg:${nord.palette.nord4.hex}";
          format = "[    $user]($style)";
        };

        git_branch = {
          symbol = "";
          style = "bg:${nord.palette.nord3.hex}";
          format = "[[  $symbol  ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord3.hex})]($style)";
        };

        git_status = {
          style = "bg:${nord.palette.nord3.hex}";
          format = "[[($all_status$ahead_behind )](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord3.hex})]($style)";
        };

        nodejs = {
          symbol = "";
          style = "bg:${nord.palette.nord2.hex}";
          format = "[[ $symbol ($version) ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord2.hex})]($style)";
        };

        bun = {
          symbol = "";
          style = "bg:${nord.palette.nord2.hex}";
          format = "[[ $symbol ($version) ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord2.hex})]($style)";
        };

        rust = {
          symbol = "";
          style = "bg:${nord.palette.nord2.hex}";
          format = "[[ $symbol ($version) ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord2.hex})]($style)";
        };

        golang = {
          symbol = "";
          style = "bg:${nord.palette.nord2.hex}";
          format = "[[ $symbol ($version) ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord2.hex})]($style)";
        };

        php = {
          symbol = "";
          style = "bg:${nord.palette.nord2.hex}";
          format = "[[ $symbol ($version) ](fg:${nord.palette.nord9.hex} bg:${nord.palette.nord2.hex})]($style)";
        };

        time = {
          disabled = true;
          time_format = "%R";
          style = "bg:${nord.palette.nord1.hex}";
        };
      };
    };
  };
}
