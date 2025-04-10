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
# Development related configurations

{ config, lib, pkgs, ... }:
let
  cfg = config.features.dev;
in
{
  options = {
    features.dev = {
      enable = lib.mkEnableOption "Development";
    };
  };

  imports = [ ./lsp.nix ];

  config = {
    programs = lib.mkIf cfg.enable {
      # dev tools, env vars, task runner (asdf-plugin compatible)
      # https://github.com/jdx/mise
      mise.enable = true;

      neovim = lib.mkIf config.programs.neovim.enable {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = nvim-treesitter.withAllGrammars;

            type = "lua";

            config = ''
              require("nvim-treesitter.configs").setup {
                auto_install = false,
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = false,
                },
              }
            '';
          }
        ];
      };
    };

    home.packages = lib.mkIf cfg.enable [
      # a structural diff tool that understands syntax
      # https://difftastic.wilfred.me.uk/
      pkgs.difftastic

      # A tool for compliance with the REUSE Initiative recommendations
      # https://reuse.software/tutorial/
      pkgs.reuse
    ];
  };

}
