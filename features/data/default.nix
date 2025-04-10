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
# Configurations for data-related tasks: inspect, modify, etc...

{ config, lib, pkgs, ... }:
{
  options = {
    features.data.enable = lib.mkEnableOption "Data";
  };

  imports = [ ./nushell.nix ];

  config = lib.mkIf config.features.data.enable {
    home.packages = with pkgs; [
      # An advanced calculator library (`qalc` command)
      # https://qalculate.github.io/
      libqalculate
    ];

    programs = {
      # JSON view/query tool
      # https://github.com/jqlang/jq
      jq = {
        enable = true;
      };
    };
  };
}
