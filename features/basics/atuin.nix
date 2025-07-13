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

{ config, pkgs, ... }:
{
  programs = {
    # Replacement for a shell history which records additional commands context
    atuin = {
      enable = true;

      enableBashIntegration = false;
      enableFishIntegration = false;

      enableNushellIntegration = true;
      enableZshIntegration = true;

      settings = {
        auto_sync = false;

        show_preview = true;

        keymap_mode = "vim-normal";

        filter_mode = "directory";

        filter_mode_shell_up_key_binding = "session";

        update_check = false;

        inline_height = 0;
      };
    };
  };
}
