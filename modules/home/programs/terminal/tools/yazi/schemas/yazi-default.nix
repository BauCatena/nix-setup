{ palette }:
{

  mgr = {
    cwd = {
      fg = palette.palette.color8.hex;
    };
    hovered = {
      reversed = true;
    };
    preview_hovered = {
      reversed = true;
    };
    find_keyword = {
      fg = palette.palette.color13.hex;
      bold = true;
      italic = true;
      reversed = true;
    };
    find_position = {
      fg = palette.palette.color15.hex;
      bg = "reset";
      bold = true;
      italic = true;
    };
    marker_copied = {
      fg = palette.palette.color14.hex;
      bg = palette.palette.color14.hex;
    };
    marker_cut = {
      fg = palette.palette.color11.hex;
      bg = palette.palette.color11.hex;
    };
    marker_marked = {
      fg = palette.palette.color7.hex;
      bg = palette.palette.color7.hex;
    };
    marker_selected = {
      fg = palette.palette.color13.hex;
      bg = palette.palette.color13.hex;
    };
    tab_active = {
      reversed = true;
    };
    tab_inactive = {
      fg = palette.palette.color3.hex;
    };
    tab_width = 1;
    count_copied = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color14.hex;
    };
    count_cut = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color11.hex;
    };
    count_selected = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color13.hex;
    };
    border_symbol = "│";
    border_style = {
      fg = palette.palette.color3.hex;
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
      fg = palette.palette.color0.hex;
      bg = palette.palette.color7.hex;
      bold = true;
    };
    inactive = {
      fg = palette.palette.color7.hex;
      bg = palette.palette.color1.hex;
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
      fg = palette.palette.color0.hex;
      bg = palette.palette.color7.hex;
      bold = true;
    };
    normal_alt = {
      fg = palette.palette.color7.hex;
      bg = palette.palette.color1.hex;
    };
    select_main = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color7.hex;
      bold = true;
    };
    select_alt = {
      fg = palette.palette.color7.hex;
      bg = palette.palette.color1.hex;
    };
    unset_main = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color11.hex;
      bold = true;
    };
    unset_alt = {
      fg = palette.palette.color11.hex;
      bg = palette.palette.color1.hex;
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
      fg = palette.palette.color3.hex;
    };
    perm_type = {
      fg = palette.palette.color9.hex;
    };
    perm_read = {
      fg = palette.palette.color13.hex;
    };
    perm_write = {
      fg = palette.palette.color11.hex;
    };
    perm_exec = {
      fg = palette.palette.color14.hex;
    };
    progress_label = {
      fg = palette.palette.color6.hex;
      bold = true;
    };
    progress_normal = {
      fg = palette.palette.color8.hex;
      bg = palette.palette.color2.hex;
    };
    progress_error = {
      fg = palette.palette.color11.hex;
      bg = palette.palette.color2.hex;
    };
  };

  pick = {
    border = {
      fg = palette.palette.color9.hex;
    };
    active = {
      fg = palette.palette.color15.hex;
      bold = true;
    };
    inactive = {
      fg = palette.palette.color4.hex;
    };
  };

  input = {
    border = {
      fg = palette.palette.color9.hex;
    };
    title = {
      fg = palette.palette.color4.hex;
    };
    value = {
      fg = palette.palette.color6.hex;
    };
    selected = {
      reversed = true;
    };
  };

  cmp = {
    border = {
      fg = palette.palette.color9.hex;
    };
  };

  tasks = {
    border = {
      fg = palette.palette.color9.hex;
    };
    title = {
      fg = palette.palette.color6.hex;
    };
    hovered = {
      fg = palette.palette.color15.hex;
      reversed = true;
    };
  };

  which = {
    mask = {
      bg = palette.palette.color1.hex;
    };
    cand = {
      fg = palette.palette.color7.hex;
    };
    rest = {
      fg = palette.palette.color3.hex;
    };
    desc = {
      fg = palette.palette.color15.hex;
    };
    separator = "  ";
    separator_style = {
      fg = palette.palette.color2.hex;
    };
  };

  help = {
    on = {
      fg = palette.palette.color7.hex;
    };
    run = {
      fg = palette.palette.color15.hex;
    };
    hovered = {
      reversed = true;
      bold = true;
    };
    footer = {
      fg = palette.palette.color0.hex;
      bg = palette.palette.color6.hex;
    };
  };

  notify = {
    title_info = {
      fg = palette.palette.color14.hex;
    };
    title_warn = {
      fg = palette.palette.color13.hex;
    };
    title_error = {
      fg = palette.palette.color11.hex;
    };
  };

  filetype = {
    rules = [
      { mime = "image/*"; fg = palette.palette.color7.hex; }
      { mime = "{audio,video}/*"; fg = palette.palette.color13.hex; }
      { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = palette.palette.color15.hex; }
      { mime = "application/{pdf,doc,rtf,odt,docx,xlsx,pptx}"; fg = palette.palette.color14.hex; }
      { url = "*"; is = "link"; fg = palette.palette.color15.hex; }
      { url = "*"; fg = palette.palette.color4.hex; }
      { url = "*/"; fg = palette.palette.color9.hex; bold = true; }
    ];
  };

  icon = {
    prepend_dirs = [
      { name = ".config"; text = "󰒓"; fg = palette.palette.color9.hex; }
      { name = ".git"; text = "󰊢"; fg = palette.palette.color9.hex; }
      { name = ".github"; text = "󰊤"; fg = palette.palette.color9.hex; }
      { name = ".npm"; text = "󰛷"; fg = palette.palette.color9.hex; }
      { name = "Downloads"; text = "󰉍"; fg = palette.palette.color9.hex; }
      { name = "Pictures"; text = "󰉏"; fg = palette.palette.color9.hex; }
      { name = "Music"; text = "󱍙"; fg = palette.palette.color9.hex; }
      { name = "Documents"; text = "󱧶"; fg = palette.palette.color9.hex; }
      { name = "Videos"; text = "󱧺"; fg = palette.palette.color9.hex; }
      { name = "Desktop"; text = "󱂵"; fg = palette.palette.color9.hex; }
      { name = "Public"; text = "󱞊"; fg = palette.palette.color9.hex; }
    ];
    prepend_conds = [
      { "if" = "dir & !hidden"; text = "󰉋"; fg = palette.palette.color9.hex; }
      { "if" = "dir & hidden"; text = "󱞞"; fg = palette.palette.color9.hex; }
      { "if" = "dir & link"; text = "󰴋"; fg = palette.palette.color9.hex; }
      { "if" = "dir & orphan"; text = "󱧸"; fg = palette.palette.color9.hex; }
    ];
  };
}
