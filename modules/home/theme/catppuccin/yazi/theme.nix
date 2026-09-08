let
  catppuccin = import ../colors.nix;
  colors = catppuccin.colors;
in
{
  mgr = {
    cwd = {
      fg = colors.blue.hex;
    };
    hovered = {
      reversed = true;
    };
    preview_hovered = {
      reversed = true;
    };
    find_keyword = {
      fg = colors.yellow.hex;
      bold = true;
      italic = true;
      reversed = true;
    };
    find_position = {
      fg = colors.mauve.hex;
      bg = "reset";
      bold = true;
      italic = true;
    };
    marker_copied = {
      fg = colors.green.hex;
      bg = colors.green.hex;
    };
    marker_cut = {
      fg = colors.red.hex;
      bg = colors.red.hex;
    };
    marker_marked = {
      fg = colors.teal.hex;
      bg = colors.teal.hex;
    };
    marker_selected = {
      fg = colors.yellow.hex;
      bg = colors.yellow.hex;
    };
    tab_active = {
      reversed = true;
    };
    tab_inactive = {
      fg = colors.overlay0.hex;
    };
    tab_width = 1;
    count_copied = {
      fg = colors.base.hex;
      bg = colors.green.hex;
    };
    count_cut = {
      fg = colors.base.hex;
      bg = colors.red.hex;
    };
    count_selected = {
      fg = colors.base.hex;
      bg = colors.yellow.hex;
    };
    border_symbol = "│";
    border_style = {
      fg = colors.overlay0.hex;
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
      fg = colors.base.hex;
      bg = colors.teal.hex;
      bold = true;
    };
    inactive = {
      fg = colors.teal.hex;
      bg = colors.surface0.hex;
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
      fg = colors.base.hex;
      bg = colors.blue.hex;
      bold = true;
    };
    normal_alt = {
      fg = colors.blue.hex;
      bg = colors.surface0.hex;
    };
    select_main = {
      fg = colors.base.hex;
      bg = colors.green.hex;
      bold = true;
    };
    select_alt = {
      fg = colors.green.hex;
      bg = colors.surface0.hex;
    };
    unset_main = {
      fg = colors.base.hex;
      bg = colors.maroon.hex;
      bold = true;
    };
    unset_alt = {
      fg = colors.maroon.hex;
      bg = colors.surface0.hex;
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
      fg = colors.overlay0.hex;
    };
    perm_type = {
      fg = colors.blue.hex;
    };
    perm_read = {
      fg = colors.yellow.hex;
    };
    perm_write = {
      fg = colors.red.hex;
    };
    perm_exec = {
      fg = colors.green.hex;
    };
    progress_label = {
      fg = colors.text.hex;
      bold = true;
    };
    progress_normal = {
      fg = colors.blue.hex;
      bg = colors.surface1.hex;
    };
    progress_error = {
      fg = colors.red.hex;
      bg = colors.surface1.hex;
    };
  };

  pick = {
    border = {
      fg = colors.blue.hex;
    };
    active = {
      fg = colors.pink.hex;
      bold = true;
    };
    inactive = {
      fg = colors.subtext0.hex;
    };
  };

  input = {
    border = {
      fg = colors.blue.hex;
    };
    title = {
      fg = colors.subtext0.hex;
    };
    value = {
      fg = colors.text.hex;
    };
    selected = {
      reversed = true;
    };
  };

  cmp = {
    border = {
      fg = colors.blue.hex;
    };
  };

  tasks = {
    border = {
      fg = colors.blue.hex;
    };
    title = {
      fg = colors.text.hex;
    };
    hovered = {
      fg = colors.mauve.hex;
      reversed = true;
      underline = true;
    };
  };

  confirm = {
    border = {
      fg = colors.blue.hex;
    };
    title = {
      fg = colors.blue.hex;
    };
    body = { };
    list = { };
    btn_yes = {
      reversed = true;
    };
    btn_no = { };
  };

  which = {
    border = {
      fg = colors.blue.hex;
    };
    mask = {
      bg = "#363a4f";
    };
    cand = {
      fg = colors.teal.hex;
    };
    rest = {
      fg = colors.overlay2.hex;
    };
    desc = {
      fg = colors.pink.hex;
    };
    separator = "  ";
    separator_style = {
      fg = colors.surface2.hex;
    };
  };

  help = {
    border = {
      fg = colors.blue.hex;
    };
    on = {
      fg = colors.teal.hex;
    };
    run = {
      fg = colors.mauve.hex;
    };
    chord = {
      fg = colors.pink.hex;
    };
    action = {
      fg = colors.teal.hex;
    };
    hovered = {
      reversed = true;
      bold = true;
    };
    footer = {
      fg = colors.base.hex;
      bg = colors.text.hex;
    };
  };

  notify = {
    title_info = {
      fg = colors.green.hex;
    };
    title_warn = {
      fg = colors.yellow.hex;
    };
    title_error = {
      fg = colors.red.hex;
    };
  };

  filetype = {
    rules = [
      { mime = "image/*"; fg = colors.teal.hex; }
      { mime = "{audio,video}/*"; fg = colors.yellow.hex; }
      { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = colors.mauve.hex; }
      { mime = "application/{pdf,doc,rtf,odt,docx,xlsx,pptx}"; fg = colors.green.hex; }
      { url = "*"; is = "link"; fg = colors.mauve.hex; }
      { url = "*"; fg = colors.subtext0.hex; }
      { url = "*/"; fg = colors.blue.hex; bold = true; }
    ];
  };

  icon = {
    prepend_dirs = [
      { name = ".config"; text = "󰒓"; fg = colors.blue.hex; }
      { name = ".git"; text = "󰊢"; fg = colors.blue.hex; }
      { name = ".github"; text = "󰊤"; fg = colors.blue.hex; }
      { name = ".npm"; text = "󰛷"; fg = colors.blue.hex; }
      { name = "Downloads"; text = "󰉍"; fg = colors.blue.hex; }
      { name = "Pictures"; text = "󰉏"; fg = colors.blue.hex; }
      { name = "Music"; text = "󱍙"; fg = colors.blue.hex; }
      { name = "Documents"; text = "󱧶"; fg = colors.blue.hex; }
      { name = "Videos"; text = "󱧺"; fg = colors.blue.hex; }
      { name = "Desktop"; text = "󱂵"; fg = colors.blue.hex; }
      { name = "Public"; text = "󱞊"; fg = colors.blue.hex; }
    ];
    prepend_conds = [
      { "if" = "dir & !hidden"; text = "󰉋"; fg = colors.blue.hex; }
      { "if" = "dir & hidden"; text = "󱞞"; fg = colors.blue.hex; }
      { "if" = "dir & link"; text = "󰴋"; fg = colors.blue.hex; }
      { "if" = "dir & orphan"; text = "󱧸"; fg = colors.blue.hex; }
    ];
  };
}
