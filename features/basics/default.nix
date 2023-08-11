{ config, lib, pkgs, ... }:
{
  imports = [
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
    ];

    # Programs available via Home Manager
    programs = {
      # For fallback purpose.
      bash = {
        enable = true;
      };

      # A modern replacement for ls.
      # https://the.exa.website/
      exa = {
        enable = true;

        # Whether to enable recommended exa aliases (ls, ll…).
        enableAliases = true;

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

      # JSON view/query tool
      # https://github.com/jqlang/jq
      jq = {
        enable = true;
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
    };
  };
}