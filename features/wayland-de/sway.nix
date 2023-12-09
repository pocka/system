{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.features.wayland-de.enable {
    wayland.windowManager.sway =
      let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
      {
        enable = true;

        # Do not install package: outside NixOS, installing Sway via Home Manager
        # does not work at all (due to factors such as deps and session config files).
        package = null;

        config = {
          bars = [
            { command = "${pkgs.waybar}/bin/waybar"; }
          ];

          terminal = "${pkgs.foot}/bin/foot";

          input = {
            "*" = {
              repeat_delay = "150";
              repeat_rate = "24";
            };

            "type:touchpad" = {
              natural_scroll = "enabled";
            };
          };
        };

        extraConfig = ''
          bindgesture swipe:3:right workspace prev
          bindgesture swipe:3:left workspace next

          set $drun tofi-drun | xargs swaymsg exec --
          unbindsym ${mod}+d
          bindsym ${mod}+d exec $drun
        '';
      };
  };
}
