# Copyright 2024 Shota FUJI <pockawoooh@gmail.com>
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
{
  config = lib.mkIf config.features.gui.enable {
    programs.ghostty = {
      enable = true;

      enableZshIntegration = true;

      package =
        if pkgs.stdenv.isDarwin then
          pkgs.nur.repos.DimitarNestorov.ghostty
        else
          config.lib.nixGL.wrap pkgs.ghostty;

      settings = {
        # Somehow Ghostty renders Monaspace in incorrect size at either of platform.
        font-size = if pkgs.stdenv.isDarwin then 14 else 11;
        font-family = "Monaspace Neon Var";
        font-style = "Medium";
        font-style-bold = "Bold";
        font-style-italic = "Medium Italic";
        font-style-bold-italic = "Bold Italic";

        # * "calt" ... Contextual Alternates
        #              This feature enables Monaspace's Texture healing.
        # * "dlig" ... Discretionary Ligatures
        #              This feature fucks up Japanese text rendering.
        #              Enabled by default.
        font-feature = [ "calt" "-dlig" ];

        copy-on-select = false;

        keybind =
          if pkgs.stdenv.isDarwin then [
            "ctrl+shift+t=new_tab"
            "ctrl+shift+n=new_split:down"
            "ctrl+shift+m=new_split:right"

            "super+shift+k=resize_split:up,20"
            "super+shift+h=resize_split:left,20"
            "super+shift+j=resize_split:down,20"
            "super+shift+l=resize_split:right,20"

            "ctrl+shift+k=goto_split:up"
            "ctrl+shift+h=goto_split:left"
            "ctrl+shift+j=goto_split:down"
            "ctrl+shift+l=goto_split:right"
          ]
          else [
            "ctrl+shift+t=new_window"
            "ctrl+shift+n=new_window"
            "ctrl+shift+m=new_window"
          ];

      };
    };
  };
}
