{
  config,
  lib,

  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.bautinix.system.xkb;
in
{
  options.bautinix.system.xkb = {
    enable = lib.mkEnableOption "xkb";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;

    services.xserver = {
      xkb = {
        layout = "us";
        options = "caps:escape";
      };
    };
  };
}
