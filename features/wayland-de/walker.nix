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
  options = {
    features.wayland-de.walker = {
      css = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };
    };
  };

  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # Multi-Purpose Launcher with a lot of features.
      # https://github.com/abenz1267/walker
      pkgs.walker
    ];

    xdg.configFile."walker/config.toml".source = ./walker/config.toml;
    xdg.configFile."walker/themes/nix.toml".source = ./walker/theme.toml;
    xdg.configFile."walker/themes/nix.css".text = ''
      ${builtins.readFile ./walker/theme.css}
      ${config.features.wayland-de.walker.css}
    '';
  };
}
