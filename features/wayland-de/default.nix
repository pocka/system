# Wayland Desktop Environment
{ lib, ... }:
{
  options = {
    features.wayland-de.enable = lib.mkEnableOption "WaylandDE";
  };

  imports = [
    ./foot.nix
  ];
}
