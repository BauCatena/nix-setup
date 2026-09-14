{ palette }:
{
  format = "$username[](bg:${palette.palette.color9.hex} fg:${palette.palette.color10.hex})$directory[](fg:${palette.palette.color9.hex} bg:${palette.palette.color3.hex})$git_branch$git_status[](fg:${palette.palette.color3.hex} bg:${palette.palette.color2.hex})$nodejs$bun$rust$golang$php[](fg:${palette.palette.color2.hex} bg:${palette.palette.color1.hex})$time[ ](fg:${palette.palette.color1.hex})$character";

  directory = {
    style = "fg:${palette.palette.color4.hex} bg:${palette.palette.color9.hex}";
    format = "[  $path  ]($style)";
    truncation_length = 4;
    truncation_symbol = "…/";
    substitutions = {
      "Documents" = "󰈙 ";
      "Downloads" = " ";
      "Music" = " ";
      "Pictures" = " ";
      "~" = " ";
    };
  };

  username = {
    show_always = true;
    disabled = false;
    style_user = "bg:${palette.palette.color10.hex} fg:${palette.palette.color4.hex}";
    format = "[     $user  ]($style)";
  };

  git_branch = {
    symbol = "";
    style = "bg:${palette.palette.color3.hex}";
    format = "[[  $symbol  ](fg:${palette.palette.color9.hex} bg:${palette.palette.color3.hex})]($style)";
  };

  git_status = {
    style = "bg:${palette.palette.color3.hex}";
    format = "[[($all_status$ahead_behind )](fg:${palette.palette.color9.hex} bg:${palette.palette.color3.hex})]($style)";
  };

  nodejs = {
    symbol = "";
    style = "bg:${palette.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${palette.palette.color9.hex} bg:${palette.palette.color2.hex})]($style)";
  };

  bun = {
    symbol = "";
    style = "bg:${palette.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${palette.palette.color9.hex} bg:${palette.palette.color2.hex})]($style)";
  };

  rust = {
    symbol = "";
    style = "bg:${palette.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${palette.palette.color9.hex} bg:${palette.palette.color2.hex})]($style)";
  };

  golang = {
    symbol = "";
    style = "bg:${palette.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${palette.palette.color9.hex} bg:${palette.palette.color2.hex})]($style)";
  };

  php = {
    symbol = "";
    style = "bg:${palette.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${palette.palette.color9.hex} bg:${palette.palette.color2.hex})]($style)";
  };

  time = {
    disabled = true;
    time_format = "%R";
    style = "bg:${palette.palette.color1.hex}";
  };
}
