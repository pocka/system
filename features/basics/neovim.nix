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

{ config, pkgs, ... }:
{
  config = {
    programs = {
      neovim = {
        enable = true;

        defaultEditor = true;

        withPython3 = false;
        withRuby = false;

        extraLuaConfig = builtins.readFile ./neovim/basic.lua;

        plugins = with pkgs.vimPlugins; [
          plenary-nvim
          {
            plugin = zen-mode-nvim;
            type = "lua";
            config = builtins.readFile ./neovim/zen-mode.lua;
          }
          {
            plugin = nvim-tree-lua;
            type = "lua";
            config = builtins.readFile ./neovim/nvim-tree.lua;
          }
          {
            plugin = telescope-nvim;
            type = "lua";
            config = builtins.readFile ./neovim/telescope.lua;
          }
          {
            plugin = telescope-file-browser-nvim;
            type = "lua";
            config = builtins.readFile ./neovim/telescope-file-browser.lua;
          }
          {
            plugin = indent-blankline-nvim;
            type = "lua";
            config = builtins.readFile ./neovim/indent-blankline.lua;
          }
          {
            plugin = lualine-nvim;
            type = "lua";
            config = builtins.readFile ./neovim/lualine.lua;
          }
        ];
      };
    };
  };
}
