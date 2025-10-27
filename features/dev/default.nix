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

{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.dev;

  toml = pkgs.formats.toml { };

  tsVala = pkgs.fetchgit {
    url = "https://codeberg.org/pocka/tree-sitter-vala";
    rev = "12617c612ae85c57041e90aef5a5bd088b1214d3";
    hash = "sha256-/5sLNewYO12tS5yeVnZsNTAxmAgQY2QEfepgB7vrJMg=";
  };

  allGrammars = (
    lib.filter (d: d.pname != "vala-grammar") pkgs.vimPlugins.nvim-treesitter.allGrammars
  );
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
            plugin = nvim-treesitter.grammarToPlugin (
              pkgs.tree-sitter.buildGrammar {
                language = "vala";
                version = "0.0.0+rev=10fb4b1";
                src = tsVala;
                meta.homepage = "https://codeberg.org/pocka/tree-sitter-vala";
              }
            );
            type = "viml";

            # Either nvim, Nix, or nvim-treesitter does bad job at runtime path resolving.
            # So it includes nvim-treesitter's **hard-coded** query directory and registers
            # that directory before this custom grammar plugin. Because of this incorrect
            # runtimepath order, nvim-treesitter uses parser from the above grammar but reads
            # its forcibly included query.
            # As ~/.config/nvim is special directory and cannot "win" in load order, an
            # another directory is needed.
            config = ''
              set rtp^=~/.config/nvim-treesitter-overrides
            '';
          }
          {
            plugin = nvim-treesitter.withPlugins (_: allGrammars);

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
          { plugin = vim-fugitive; }
        ];
      };
    };

    # home-manager puts global config to `.config/mise/config.toml`, which
    # mise writes to on `mise settings` command.
    xdg.configFile."mise/conf.d/immutable.toml" = lib.mkIf cfg.enable {
      source = toml.generate "mise-settings" {
        settings = {
          idiomatic_version_file_enable_tools = [
            "bazel"
            "node"
          ];
        };
      };
    };

    # Have to explicitly disable default highlight query.
    # https://github.com/nvim-treesitter/nvim-treesitter/issues/3146
    xdg.configFile."nvim-treesitter-overrides/queries/vala/highlights.scm" =
      lib.mkIf cfg.enable
        { source = tsVala + "/queries/highlights.scm"; };

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
