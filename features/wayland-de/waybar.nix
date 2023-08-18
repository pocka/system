{ config, lib, pkgs, ... }: {
  programs =
    lib.mkIf config.features.wayland-de.enable {
      waybar = {
        enable = true;

        settings = {
          main = {
            layer = "top";

            modules-left = [ "sway/workspaces" "sway/mode" ];
            modules-right = [ "clock" "network" "pulseaudio" "tray" ];

            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
              format = "{name}";
            };

            clock = {
              # waybar can't read $TZ. Maybe a bug with Nix environment?
              timezone = config.features.home.timezone;
              locale = config.features.home.locale;
              format = "{:%Y-%m-%d %H:%M}";
            };

            pulseaudio = {
              format = "{icon} {volume}% / {format_source}";
              format-muted = "muted {format_source}";

              on-click = "pavucontrol";
            };
          };
        };
      };
    };
}

