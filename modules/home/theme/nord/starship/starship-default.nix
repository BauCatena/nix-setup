{ palette }:
let
  nord = { inherit palette; };
in 
{
  format = "$username[](bg:${nord.palette.color9.hex} fg:${nord.palette.color10.hex})$directory[](fg:${nord.palette.color9.hex} bg:${nord.palette.color3.hex})$git_branch$git_status[](fg:${nord.palette.color3.hex} bg:${nord.palette.color2.hex})$nodejs$bun$rust$golang$php[](fg:${nord.palette.color2.hex} bg:${nord.palette.color1.hex})$time[ ](fg:${nord.palette.color1.hex})$character";

  directory = {
    style = "fg:${nord.palette.color4.hex} bg:${nord.palette.color9.hex}";
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
    style_user = "bg:${nord.palette.color10.hex} fg:${nord.palette.color4.hex}";
    format = "[     $user  ]($style)";
  };

  git_branch = {
    symbol = "";
    style = "bg:${nord.palette.color3.hex}";
    format = "[[  $symbol  ](fg:${nord.palette.color9.hex} bg:${nord.palette.color3.hex})]($style)";
  };

  git_status = {
    style = "bg:${nord.palette.color3.hex}";
    format = "[[($all_status$ahead_behind )](fg:${nord.palette.color9.hex} bg:${nord.palette.color3.hex})]($style)";
  };

  nodejs = {
    symbol = "";
    style = "bg:${nord.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${nord.palette.color9.hex} bg:${nord.palette.color2.hex})]($style)";
  };

  bun = {
    symbol = "";
    style = "bg:${nord.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${nord.palette.color9.hex} bg:${nord.palette.color2.hex})]($style)";
  };

  rust = {
    symbol = "";
    style = "bg:${nord.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${nord.palette.color9.hex} bg:${nord.palette.color2.hex})]($style)";
  };

  golang = {
    symbol = "";
    style = "bg:${nord.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${nord.palette.color9.hex} bg:${nord.palette.color2.hex})]($style)";
  };

  php = {
    symbol = "";
    style = "bg:${nord.palette.color2.hex}";
    format = "[[ $symbol ($version) ](fg:${nord.palette.color9.hex} bg:${nord.palette.color2.hex})]($style)";
  };

  time = {
    disabled = true;
    time_format = "%R";
    style = "bg:${nord.palette.color1.hex}";
  };
}
