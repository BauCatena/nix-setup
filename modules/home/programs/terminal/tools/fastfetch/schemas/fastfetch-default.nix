let
  cLogo1 = "#5b87b0";
  cLogo2 = "#89d5e0";
  cGray = "#727272";
  cDarkGray = "#575757";
  cBlue = "#7E97AB";
  cValue = "#88afa2";
in
{
  "$schema" = "https://github.com/fastfetch-cli/fastfetch/blob/dev/doc/json_schema.json";
  logo = {
    source = "nixos";
    preserveAspectRatio = true;
    padding = {
      top = 0;
      left = 0;
    };
    color = {
      "1" = cLogo1;
      "2" = cLogo2;
      "3" = cLogo1;
      "4" = cLogo2;
      "5" = cLogo1;
      "6" = cLogo2;
    };
  };
  display = {
    separator = " ";
    color = {
      keys = "white";
      title = "white";
    };
  };
  modules = [
    "break"
    {
      type = "custom";
      format = "{#${cGray}}{{";
    }
    {
      type = "os";
      key = "  {#${cDarkGray}}system.{#${cBlue}}os         {#${cGray}}= ";
      format = "{#${cValue}}\"{name} {version} ({codename})\"{#${cGray}};";
    }
    {
      type = "locale";
      key = "  {#${cDarkGray}}system.{#${cBlue}}locale     {#${cGray}}= ";
      format = "{#${cValue}}\"{result}\"{#${cGray}};";
    }
    {
      type = "uptime";
      key = "  {#${cDarkGray}}system.{#${cBlue}}uptime     {#${cGray}}= ";
      format = "{#${cValue}}\"{days} days, {hours} hours, {minutes} mins\"{#${cGray}};";
    }
    "break"
    {
      type = "cpu";
      key = "  {#${cDarkGray}}hardware.{#${cBlue}}cpu      {#${cGray}}= ";
      format = "{#${cValue}}\"{name} ({cores-logical}) @ {freq-max}\"{#${cGray}};";
    }
    {
      type = "gpu";
      key = "  {#${cDarkGray}}hardware.{#${cBlue}}gpu      {#${cGray}}= ";
      format = "{#${cValue}}\"{name}\"{#${cGray}};";
    }
    {
      type = "memory";
      key = "  {#${cDarkGray}}hardware.{#${cBlue}}ram      {#${cGray}}= ";
      format = "{#${cValue}}\"{used<10} / {total>9}\"{#${cGray}}";
    }
    {
      type = "disk";
      folders = "/";
      key = "  {#${cDarkGray}}hardware.{#${cBlue}}disk0    {#${cGray}}= ";
      format = "{#${cValue}}\"{size-used<10} / {size-total>9}\"{#${cGray}}";
    }
    {
      type = "disk";
      folders = "/srv/media";
      key = "  {#${cDarkGray}}hardware.{#${cBlue}}disk1    {#${cGray}}= ";
      format = "{#${cValue}}\"{size-used<10} / {size-total>9}\"{#${cGray}};  {#${cDarkGray}}# {size-percentage}";
    }
    "break"
    {
      type = "de";
      key = "  {#${cDarkGray}}desktop.{#${cBlue}}de         {#${cGray}}= ";
      format = "{#${cValue}}\"{pretty-name} {version}\"{#${cGray}};";
    }
    {
      type = "wm";
      key = "  {#${cDarkGray}}desktop.{#${cBlue}}wm         {#${cGray}}= ";
      format = "{#${cValue}}\"{pretty-name} ({protocol-name})\"{#${cGray}};";
    }
    {
      type = "display";
      key = "  {#${cDarkGray}}desktop.{#${cBlue}}display    {#${cGray}}= ";
      format = "{#${cValue}}\"{width}x{height} @ {refresh-rate}Hz\"{#${cGray}};";
    }
    {
      type = "localip";
      key = "  {#${cDarkGray}}desktop.{#${cBlue}}localIp    {#${cGray}}= ";
      format = "{#${cValue}}\"{ipv4}\"{#${cGray}};";
    }
    "break"
    {
      type = "shell";
      key = "  {#${cDarkGray}}terminal.{#${cBlue}}shell     {#${cGray}}= ";
      format = "{#${cValue}}\"{pretty-name} {version}\"{#${cGray}};";
    }
    {
      type = "terminal";
      key = "  {#${cDarkGray}}terminal.{#${cBlue}}term      {#${cGray}}= ";
      format = "{#${cValue}}\"{pretty-name}\"{#${cGray}};";
    }
    {
      type = "packages";
      key = "  {#${cDarkGray}}terminal.{#${cBlue}}packages {#${cGray}}= ";
      format = "{#${cGray}}[ {#${cValue}}\"{nix-system} nix-system\" \"{nix-user} nix-user\"{#${cGray}} ];";
    }
    {
      type = "custom";
      format = "{#${cGray}}}";
    }
    "break"
  ];
}
