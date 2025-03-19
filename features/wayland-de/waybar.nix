{ config, lib, pkgs, ... }: {
  programs =
    lib.mkIf config.features.wayland-de.enable {
      waybar = {
        enable = true;

        settings = {
          main = {
            layer = "top";

            modules-left = [ ];
            modules-right = [ "clock" "pulseaudio" "tray" ];

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

