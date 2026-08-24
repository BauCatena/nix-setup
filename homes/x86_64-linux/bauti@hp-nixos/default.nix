{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:
{

  bautinix.nixos.user = {
      
      enable = true;
      name = "bauti";

    };

}

