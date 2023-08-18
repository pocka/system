# Wayland Desktop Environment
{ config, lib, pkgs, ... }:
{
  options.features.wayland-de = {
    enable = lib.mkEnableOption "WaylandDE";
  };

  imports = [
    ./foot.nix
    ./sway.nix
    ./swaybg.nix
    ./tofi.nix
    ./fcitx5.nix
    ./dunst.nix
    ./waybar.nix
  ];

  config = lib.mkIf config.features.wayland-de.enable {
    home.sessionVariables = {
      # By default, Firefox and Thunderbird uses X11.
      # Users need to explicitly set the env (it sucks).
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}
