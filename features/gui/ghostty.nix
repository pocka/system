# Copyright 2024 Shota FUJI <pockawoooh@gmail.com>
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
  config = lib.mkIf config.features.gui.enable {
    programs.ghostty = {
      enable = true;

      enableZshIntegration = true;

      package =
        if pkgs.stdenv.isDarwin then
          pkgs.nur.repos.DimitarNestorov.ghostty
        else
          config.lib.nixGL.wrap pkgs.ghostty;

      installBatSyntax = !pkgs.stdenv.isDarwin;

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
