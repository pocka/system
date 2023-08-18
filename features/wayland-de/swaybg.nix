{ config, lib, pkgs, ... }:
let
  cfg = config.features.wayland-de.swaybg;
in
{
  options.features.wayland-de.swaybg = {
    background = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "#000000";
      description = ''
        The background color.
      '';
    };

    image = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        The path of the background image file.
      '';
    };
  };

  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # Wallpaper tool for Wayland compositors
      # https://github.com/swaywm/swaybg
      pkgs.swaybg
    ];

    wayland.windowManager.sway.extraConfig =
      let
        bg = "--color '${cfg.background}'";
        image =
          if builtins.isNull cfg.image then
            ""
          else
            "--image ${builtins.toString cfg.image}";
      in
      ''
        exec "${pkgs.swaybg}/bin/swaybg ${bg} ${image}"
      '';
  };
}
