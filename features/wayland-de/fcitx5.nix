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

{ config, lib, pkgs, ... }:
let
  wayland-de = config.features.wayland-de;
in
{
  options = {
    features.wayland-de.ime = {
      enable = lib.mkEnableOption "Input method";
    };
  };

  config = lib.mkIf (wayland-de.enable && wayland-de.ime.enable) {
    i18n.inputMethod = {
      enabled = "fcitx5";

      fcitx5 = {
        waylandFrontend = true;

        addons = [
          pkgs.fcitx5-mozc
          pkgs.fcitx5-gtk
          pkgs.libsForQt5.fcitx5-qt
        ];
      };
    };
  };
}
