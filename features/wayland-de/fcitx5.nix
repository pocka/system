{ config, lib, pkgs, ... }: let
  wayland-de = config.features.wayland-de;
in {
  options = {
    features.wayland-de.ime = {
      enable = lib.mkEnableOption "Input method";
    };
  };

  config = lib.mkIf (wayland-de.enable && wayland-de.ime.enable) {
    i18n.inputMethod = {
      enabled = "fcitx5";

      fcitx5.addons = [
        pkgs.fcitx5-mozc
        pkgs.fcitx5-gtk
        pkgs.libsForQt5.fcitx5-qt
      ];
    };
  };
}


