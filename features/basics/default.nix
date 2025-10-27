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

{
  config,
  lib,
  pkgs,
  ...
}:
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

      # A tool to fix `nix-shell` and `nix develop` forcibly use bash
      # https://github.com/MercuryTechnologies/nix-your-shell
      pkgs.nix-your-shell

      # Spell checker
      (pkgs.aspellWithDicts (
        dicts: with dicts; [
          en
          en-computers
        ]
      ))
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

      fish = {
        enable = true;
        interactiveShellInit = builtins.readFile ./init.fish;
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
          openCommand = if pkgs.stdenv.isLinux then "xdg-open" else "open";
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

        arguments = [ "--sort=path" ];
      };
    };
  };
}
