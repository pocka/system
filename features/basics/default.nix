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
      };
    };
  };
}
