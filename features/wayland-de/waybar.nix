# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# SPDX-License-Identifier: 0BSD

{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # /programs/waybar-text
      pkgs.my-waybar-text
    ];

    programs = {
      waybar = {
        enable = true;

        settings = {
          main = {
            layer = "top";

            modules-left = [ "custom/todo" ];
            modules-right = [
              "clock"
              "pulseaudio"
              "tray"
            ];

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

            "custom/todo" = {
              exec = "${pkgs.my-waybar-text}/bin/,waybar-text --trim-md-list ${config.xdg.dataHome}/todo.md";
              restart-interval = 10;
              return-type = "json";
            };
          };
        };
      };
    };
  };
}
