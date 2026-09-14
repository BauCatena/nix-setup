{ palette, ... }:
let
  nord = { inherit palette; };
in
{

  mgr = {
    cwd = {
      fg = nord.palette.color8.hex;
    };
    hovered = {
      reversed = true;
    };
    preview_hovered = {
      reversed = true;
    };
    find_keyword = {
      fg = nord.palette.color13.hex;
      bold = true;
      italic = true;
      reversed = true;
    };
    find_position = {
      fg = nord.palette.color15.hex;
      bg = "reset";
      bold = true;
      italic = true;
    };
    marker_copied = {
      fg = nord.palette.color14.hex;
      bg = nord.palette.color14.hex;
    };
    marker_cut = {
      fg = nord.palette.color11.hex;
      bg = nord.palette.color11.hex;
    };
    marker_marked = {
      fg = nord.palette.color7.hex;
      bg = nord.palette.color7.hex;
    };
    marker_selected = {
      fg = nord.palette.color13.hex;
      bg = nord.palette.color13.hex;
    };
    tab_active = {
      reversed = true;
    };
    tab_inactive = {
      fg = nord.palette.color3.hex;
    };
    tab_width = 1;
    count_copied = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color14.hex;
    };
    count_cut = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color11.hex;
    };
    count_selected = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color13.hex;
    };
    border_symbol = "│";
    border_style = {
      fg = nord.palette.color3.hex;
    };
  };

  tabs = {
    sep_outer = {
     open = "▐";
     close = "";
    };
    sep_inner = {
      open = "▐";
      close = "";
    };
    active = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color7.hex;
      bold = true;
    };
    inactive = {
      fg = nord.palette.color7.hex;
      bg = nord.palette.color1.hex;
    };
  };

  indicator = {
    padding = {
      open = "▐";
      close = "";
    };
    parent = {
      reversed = true;
    };

    preview = {
      dim = true;
      underline = true;
    };
  };

  mode = {
    normal_main = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color7.hex;
      bold = true;
    };
    normal_alt = {
      fg = nord.palette.color7.hex;
      bg = nord.palette.color1.hex;
    };
    select_main = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color7.hex;
      bold = true;
    };
    select_alt = {
      fg = nord.palette.color7.hex;
      bg = nord.palette.color1.hex;
    };
    unset_main = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color11.hex;
      bold = true;
    };
    unset_alt = {
      fg = nord.palette.color11.hex;
      bg = nord.palette.color1.hex;
    };
  };

  status = {
    sep_right = {
      open = "";
      close = "▌";
    };
   sep_left = {
      open = "▐";
      close = "";
    };
    perm_sep = {
      fg = nord.palette.color3.hex;
    };
    perm_type = {
      fg = nord.palette.color9.hex;
    };
    perm_read = {
      fg = nord.palette.color13.hex;
    };
    perm_write = {
      fg = nord.palette.color11.hex;
    };
    perm_exec = {
      fg = nord.palette.color14.hex;
    };
    progress_label = {
      fg = nord.palette.color6.hex;
      bold = true;
    };
    progress_normal = {
      fg = nord.palette.color8.hex;
      bg = nord.palette.color2.hex;
    };
    progress_error = {
      fg = nord.palette.color11.hex;
      bg = nord.palette.color2.hex;
    };
  };

  pick = {
    border = {
      fg = nord.palette.color9.hex;
    };
    active = {
      fg = nord.palette.color15.hex;
      bold = true;
    };
    inactive = {
      fg = nord.palette.color4.hex;
    };
  };

  input = {
    border = {
      fg = nord.palette.color9.hex;
    };
    title = {
      fg = nord.palette.color4.hex;
    };
    value = {
      fg = nord.palette.color6.hex;
    };
    selected = {
      reversed = true;
    };
  };

  cmp = {
    border = {
      fg = nord.palette.color9.hex;
    };
  };

  tasks = {
    border = {
      fg = nord.palette.color9.hex;
    };
    title = {
      fg = nord.palette.color6.hex;
    };
    hovered = {
      fg = nord.palette.color15.hex;
      reversed = true;
    };
  };

  which = {
    mask = {
      bg = nord.palette.color1.hex;
    };
    cand = {
      fg = nord.palette.color7.hex;
    };
    rest = {
      fg = nord.palette.color3.hex;
    };
    desc = {
      fg = nord.palette.color15.hex;
    };
    separator = "  ";
    separator_style = {
      fg = nord.palette.color2.hex;
    };
  };

  help = {
    on = {
      fg = nord.palette.color7.hex;
    };
    run = {
      fg = nord.palette.color15.hex;
    };
    hovered = {
      reversed = true;
      bold = true;
    };
    footer = {
      fg = nord.palette.color0.hex;
      bg = nord.palette.color6.hex;
    };
  };

  notify = {
    title_info = {
      fg = nord.palette.color14.hex;
    };
    title_warn = {
      fg = nord.palette.color13.hex;
    };
    title_error = {
      fg = nord.palette.color11.hex;
    };
  };

  filetype = {
    rules = [
      { mime = "image/*"; fg = nord.palette.color7.hex; }
      { mime = "{audio,video}/*"; fg = nord.palette.color13.hex; }
      { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = nord.palette.color15.hex; }
      { mime = "application/{pdf,doc,rtf,odt,docx,xlsx,pptx}"; fg = nord.palette.color14.hex; }
      { url = "*"; is = "link"; fg = nord.palette.color15.hex; }
      { url = "*"; fg = nord.palette.color4.hex; }
      { url = "*/"; fg = nord.palette.color9.hex; bold = true; }
    ];
  };

  icon = {
    prepend_dirs = [
      { name = ".config"; text = "󰒓"; fg = nord.palette.color9.hex; }
      { name = ".git"; text = "󰊢"; fg = nord.palette.color9.hex; }
      { name = ".github"; text = "󰊤"; fg = nord.palette.color9.hex; }
      { name = ".npm"; text = "󰛷"; fg = nord.palette.color9.hex; }
      { name = "Downloads"; text = "󰉍"; fg = nord.palette.color9.hex; }
      { name = "Pictures"; text = "󰉏"; fg = nord.palette.color9.hex; }
      { name = "Music"; text = "󱍙"; fg = nord.palette.color9.hex; }
      { name = "Documents"; text = "󱧶"; fg = nord.palette.color9.hex; }
      { name = "Videos"; text = "󱧺"; fg = nord.palette.color9.hex; }
      { name = "Desktop"; text = "󱂵"; fg = nord.palette.color9.hex; }
      { name = "Public"; text = "󱞊"; fg = nord.palette.color9.hex; }
    ];
    prepend_conds = [
      { "if" = "dir & !hidden"; text = "󰉋"; fg = nord.palette.color9.hex; }
      { "if" = "dir & hidden"; text = "󱞞"; fg = nord.palette.color9.hex; }
      { "if" = "dir & link"; text = "󰴋"; fg = nord.palette.color9.hex; }
      { "if" = "dir & orphan"; text = "󱧸"; fg = nord.palette.color9.hex; }
    ];
  };
}
