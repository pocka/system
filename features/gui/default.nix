{ config, lib, ... }:
{
  options = {
    features.gui.enable = lib.mkEnableOption "GUI";
  };

  imports = [
    ./kitty.nix
  ];
}
