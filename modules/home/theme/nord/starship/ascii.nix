{ palette }:
let
  nord = { inherit palette; };
in 

{
  format = "[{](fg:${nord.palette.color4.hex})$username$hostname[}](fg:${nord.palette.color4.hex}) [{](fg:${nord.palette.color4.hex})$directory[}](fg:${nord.palette.color4.hex}) [{](fg:${nord.palette.color4.hex})$git_branch[}](fg:${nord.palette.color4.hex}) [{](fg:${nord.palette.color4.hex})$time[}](fg:${nord.palette.color4.hex}) $character";

  username = {
    show_always = true;
    style_user = "fg:${nord.palette.color4.hex}";
    format = "[user: ](fg:${nord.palette.color8.hex})[$user]($style)";
  };

  hostname = {
    ssh_only = false;
    style = "fg:${nord.palette.color3.hex}";
    format = "[@$hostname]($style)";
  };

  directory = {
    style = "fg:${nord.palette.color10.hex}";
    format = "[dir: ](fg:${nord.palette.color8.hex})[$path]($style)";
    truncation_length = 2;
    truncation_symbol = "…/";
  };

  git_branch = {
    style = "fg:${nord.palette.color5.hex}";
    format = "[branch: ](fg:${nord.palette.color8.hex})[$branch]($style)";
  };

  time = {
    disabled = false;
    time_format = "%R";
    style = "fg:${nord.palette.color2.hex}";
    format = "[time: ](fg:${nord.palette.color8.hex})[$time]($style)";
  };

  character = {
    success_symbol = "[λ](bold fg:${nord.palette.color4.hex})";
    error_symbol = "[λ](bold fg:${nord.palette.color1.hex})";
  };
}
