{ config, lib, pkgs, ... }:
let
  cfg = config.features.wayland-de.swaylock;
in
{
  options = {
    features.wayland-de.swaylock = {
      flags = lib.mkOption {
        type = lib.types.listOf lib.types.string;
        default = [ ];
      };
    };
  };

  config = lib.mkIf config.features.wayland-de.enable {
    xdg.configFile."swaylock/config" = {
      text = builtins.concatStringsSep "\n" cfg.flags;
    };
  };
}
