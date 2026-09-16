{ palette }:
{
  format = "[{](fg:${palette.palette.color4.hex})$username$hostname[}](fg:${palette.palette.color4.hex}) [{](fg:${palette.palette.color4.hex})$directory[}](fg:${palette.palette.color4.hex}) [{](fg:${palette.palette.color4.hex})$git_branch[}](fg:${palette.palette.color4.hex}) [{](fg:${palette.palette.color4.hex})$time[}](fg:${palette.palette.color4.hex}) $character";

  username = {
    show_always = true;
    style_user = "fg:${palette.palette.color4.hex}";
    format = "[user: ](fg:${palette.palette.color8.hex})[$user]($style)";
  };

  hostname = {
    ssh_only = false;
    style = "fg:${palette.palette.color3.hex}";
    format = "[@$hostname]($style)";
  };

  directory = {
    style = "fg:${palette.palette.color10.hex}";
    format = "[dir: ](fg:${palette.palette.color8.hex})[$path]($style)";
    truncation_length = 2;
    truncation_symbol = "…/";
  };

  git_branch = {
    style = "fg:${palette.palette.color5.hex}";
    format = "[branch: ](fg:${palette.palette.color8.hex})[$branch]($style)";
  };

  time = {
    disabled = false;
    time_format = "%R";
    style = "fg:${palette.palette.color2.hex}";
    format = "[time: ](fg:${palette.palette.color8.hex})[$time]($style)";
  };

  character = {
    success_symbol = "[λ](bold fg:${palette.palette.color4.hex})";
    error_symbol = "[λ](bold fg:${palette.palette.color1.hex})";
  };
}
