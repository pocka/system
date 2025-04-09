# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
#
# ===
# Wayland Desktop Environment

{ config, lib, pkgs, ... }:
{
  options.features.wayland-de = {
    enable = lib.mkEnableOption "WaylandDE";
  };

  imports = [
    ./niri.nix
    ./swaylock.nix
    ./tofi.nix
    ./fcitx5.nix
    ./dunst.nix
    ./waybar.nix
  ];

  config = lib.mkIf config.features.wayland-de.enable {
    home.packages = [
      # https://monaspace.githubnext.com/
      pkgs.monaspace
    ];

    home.sessionVariables = {
      # By default, Firefox and Thunderbird uses X11.
      # Users need to explicitly set the env (it sucks).
      MOZ_ENABLE_WAYLAND = "1";
    };

    features.wayland-de.niri.spawn-at-startup = [
      [ "${pkgs.waybar}/bin/waybar" ]
    ];
  };
}
