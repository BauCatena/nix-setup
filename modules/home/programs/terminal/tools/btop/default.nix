{ config, lib, pkgs, ... }:
let
  cfg = config.bautinix.programs.terminal.tools.btop;
  
  currentTheme = lib.toLower (config.bautinix.theme.wallpaper.theme);

  palette = import ../../../../theme/${currentTheme}/colors.nix;

  btopTheme = ''
    # Bashtop theme with ${currentTheme} palette
    theme[main_bg]=""
    theme[main_fg]="${palette.palette.color4.hex}"
    theme[title]="${palette.palette.color7.hex}"
    theme[hi_fg]="${palette.palette.color10.hex}"
    theme[selected_bg]="${palette.palette.color3.hex}"
    theme[selected_fg]="${palette.palette.color6.hex}"
    theme[inactive_fg]="${palette.palette.color3.hex}"
    theme[proc_misc]="${palette.palette.color10.hex}"
    theme[cpu_box]="${palette.palette.color3.hex}"
    theme[mem_box]="${palette.palette.color3.hex}"
    theme[net_box]="${palette.palette.color3.hex}"
    theme[proc_box]="${palette.palette.color3.hex}"
    theme[div_line]="${palette.palette.color3.hex}"

    theme[temp_start]="${palette.palette.color9.hex}"
    theme[temp_mid]="${palette.palette.color8.hex}"
    theme[temp_end]="${palette.palette.color6.hex}"

    theme[cpu_start]="${palette.palette.color9.hex}"
    theme[cpu_mid]="${palette.palette.color8.hex}"
    theme[cpu_end]="${palette.palette.color6.hex}"

    theme[free_start]="${palette.palette.color9.hex}"
    theme[free_mid]="${palette.palette.color8.hex}"
    theme[free_end]="${palette.palette.color6.hex}"

    theme[cached_start]="${palette.palette.color9.hex}"
    theme[cached_mid]="${palette.palette.color8.hex}"
    theme[cached_end]="${palette.palette.color6.hex}"

    theme[available_start]="${palette.palette.color9.hex}"
    theme[available_mid]="${palette.palette.color8.hex}"
    theme[available_end]="${palette.palette.color6.hex}"

    theme[used_start]="${palette.palette.color9.hex}"
    theme[used_mid]="${palette.palette.color8.hex}"
    theme[used_end]="${palette.palette.color6.hex}"

    theme[download_start]="${palette.palette.color9.hex}"
    theme[download_mid]="${palette.palette.color8.hex}"
    theme[download_end]="${palette.palette.color6.hex}"

    theme[upload_start]="${palette.palette.color9.hex}"
    theme[upload_mid]="${palette.palette.color8.hex}"
    theme[upload_end]="${palette.palette.color6.hex}"
  '';
in
{
  options.bautinix.programs.terminal.tools.btop.enable =
    lib.mkEnableOption "btop";

  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = lib.mkDefault {
        color_theme = "bautinix";
      };
      themes.bautinix = btopTheme;
    };
  };
}
