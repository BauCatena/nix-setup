let
  catppuccin = import ../colors.nix;
in 
{
  format = "$hostname$username[](bg:${catppuccin.palette.surface0.hex} fg:${catppuccin.palette.mauve.hex})$directory[](fg:${catppuccin.palette.surface0.hex} bg:${catppuccin.palette.blue.hex})$git_branch$git_status[](fg:${catppuccin.palette.blue.hex} bg:${catppuccin.palette.yellow.hex})$nodejs$bun$rust$golang$php[](fg:${catppuccin.palette.yellow.hex} bg:${catppuccin.palette.green.hex})$time[ ](fg:${catppuccin.palette.green.hex})$character";

  directory = {
    style = "fg:${catppuccin.palette.text.hex} bg:${catppuccin.palette.surface0.hex}";
    format = "[  $path  ]($style)";
    truncation_length = 4;
    truncation_symbol = "…/";
    substitutions = {
      "~" = " ";
    };
  };

  username = {
    show_always = true;
    disabled = false;
    style_user = "bg:${catppuccin.palette.mauve.hex} fg:${catppuccin.palette.base.hex}";
    format = "[     $user  ]($style)";
  };
  hostname = {
    style = "bg:${catppuccin.palette.mauve.hex} fg:${catppuccin.palette.base.hex}";
    ssh_symbol = "";
    format = "[ $hostname]($style)";
  };

  git_branch = {
    symbol = "";
    style = "bg:${catppuccin.palette.surface1.hex}";
    format = "[[  $symbol  ](fg:${catppuccin.palette.base.hex} bg:${catppuccin.palette.blue.hex})]($style)";
  };

  git_status = {
    style = "bg:${catppuccin.palette.surface1.hex}";
    format = "[[($all_status$ahead_behind )](fg:${catppuccin.palette.base.hex} bg:${catppuccin.palette.blue.hex})]($style)";
  };

  nodejs = {
    symbol = "";
    style = "bg:${catppuccin.palette.yellow.hex}";
    format = "[[ $symbol ($version) ](fg:${catppuccin.palette.green.hex} bg:${catppuccin.palette.yellow.hex})]($style)";
  };

  bun = {
    symbol = "";
    style = "bg:${catppuccin.palette.yellow.hex}";
    format = "[[ $symbol ($version) ](fg:${catppuccin.palette.yellow.hex} bg:${catppuccin.palette.yellow.hex})]($style)";
  };

  rust = {
    symbol = "";
    style = "bg:${catppuccin.palette.yellow.hex}";
    format = "[[ $symbol ($version) ](fg:${catppuccin.palette.peach.hex} bg:${catppuccin.palette.yellow.hex})]($style)";
  };

  golang = {
    symbol = "";
    style = "bg:${catppuccin.palette.yellow.hex}";
    format = "[[ $symbol ($version) ](fg:${catppuccin.palette.blue.hex} bg:${catppuccin.palette.yellow.hex})]($style)";
  };

  php = {
    symbol = "";
    style = "bg:${catppuccin.palette.yellow.hex}";
    format = "[[ $symbol ($version) ](fg:${catppuccin.palette.lavender.hex} bg:${catppuccin.palette.yellow.hex})]($style)";
  };

  time = {
    disabled = true;
    time_format = "%R";
    style = "bg:${catppuccin.palette.base.hex}";
  };
}
