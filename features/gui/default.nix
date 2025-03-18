{ config, lib, pkgs, ... }:
{
  options = {
    features.gui.enable = lib.mkEnableOption "GUI";
  };

  config = {
    home.packages = [
      # https://monaspace.githubnext.com/
      pkgs.monaspace
    ];
  };

  imports = [
    ./ghostty.nix
  ];
}
