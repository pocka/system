# Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
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

{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # /programs/theme
      pkgs.my-theme
    ];

    systemd.user.services.my-theme = {
      Unit = {
        Description = "Apply appearance theme based on time";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.my-theme}/bin/,theme auto";
      };
    };

    systemd.user.timers.my-theme = {
      Unit = {
        Description = "Apply appearance theme periodically and at start up";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };

      Timer = {
        OnCalendar = "hourly";
        Persistent = true;
      };
    };
  };
}
