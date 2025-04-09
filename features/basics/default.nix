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
{
  imports = [
    ./atuin.nix
    ./platform.nix
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  config = {
    home.packages = [
      # Must-have networking CLI tool
      # https://curl.se/
      pkgs.curl

      # Command to produce a depth indented directory listing
      pkgs.tree
    ];

    home.file = {
      ".editorconfig".text = ''
        root = true

        [*]
        charset = utf-8
        end_of_line = lf
        insert_final_newline = true
        indent_style = tab
        indent_size = 2
      '';
    };

    # Programs available via Home Manager
    programs = {
      # For fallback purpose.
      bash = {
        enable = true;
      };

      # A modal text editor with insane selection -> action model.
      helix = {
        enable = true;

        settings = {
          theme = "base16_default";

          editor = {
            auto-pairs = false;

            indent-guides = {
              render = true;
              skip-levels = 1;
            };

            file-picker = {
              # Prevent file picker from ignoring dotfiles.
              hidden = false;
            };

            auto-format = false;
          };
        };
      };

      # A modern replacement for ls (fork of exa).
      # https://eza.rocks/
      eza = {
        enable = true;

        # Enable recommended exa aliases (ls, ll…).
        enableZshIntegration = true;

        extraOptions = [
          "--long"
          "--all"
        ];
      };

      # A terminal file manager written in Go with a heavy inspiration from ranger file manager.
      # https://github.com/gokcehan/lf
      lf =
        let
          # Linux: xdg-open
          # macOS: open
          openCommand =
            if pkgs.stdenv.isLinux
            then "xdg-open"
            else "open";
        in
        {
          enable = true;

          commands = {
            # Open text files with nvim
            open = ''
              ''${{
                case $(file --mime-type -Lb $f) in
                  text/*) nvim $fx;;
                  *) for f in $fx; do ${openCommand} $f > /dev/null 2> /dev/null & done;;
                esac
              }}
            '';
          };
        };

      # Colourful `cat`
      # https://github.com/sharkdp/bat
      bat = {
        enable = true;

        config = {
          # Use ANSI colors
          theme = "ansi";
        };
      };

      # `top` alternative
      # https://htop.dev/
      htop = {
        enable = true;
      };

      # ripgrep recursively searches directories for a regex pattern while respecting your gitignore
      # (this program is required for telescope-nvim's live_grep to work)
      # https://github.com/BurntSushi/ripgrep
      ripgrep = {
        enable = true;

        arguments = [
          "--sort=path"
        ];
      };
    };
  };
}
