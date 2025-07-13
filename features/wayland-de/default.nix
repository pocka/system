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
#
# ===
# Wayland Desktop Environment

{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.features.wayland-de = {
    enable = lib.mkEnableOption "WaylandDE";
  };

  imports = [
    ./niri.nix
    ./swaylock.nix
    ./fcitx5.nix
    ./my-theme.nix
    ./dunst.nix
    ./walker.nix
    ./waybar.nix
  ];

  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # https://monaspace.githubnext.com/
      pkgs.monaspace

      # https://www.brailleinstitute.org/freefont/
      pkgs.atkinson-hyperlegible-next
    ];

    home.sessionVariables = {
      # By default, Firefox and Thunderbird uses X11.
      # Users need to explicitly set the env (it sucks).
      MOZ_ENABLE_WAYLAND = "1";
    };

    features.wayland-de.niri.spawn-at-startup = [ [ "${pkgs.waybar}/bin/waybar" ] ];
  };
}
