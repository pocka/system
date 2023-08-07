{
  catppuccinTheme,
}:
{
  config,
  pkgs,
  ...
}:
{
  home.packages = [
    # Must-have networking CLI tool
    # https://curl.se/
    pkgs.curl


    # A generator for LS_COLORS with support for multiple color themes
    # https://github.com/sharkdp/vivid
    pkgs.vivid
  ];

  home.sessionVariables = {
    # Colourise exa, ls, lf, etc...
    LS_COLORS = "$(vivid generate catppuccin-${catppuccinTheme})";
  };

  # Programs available via Home Manager
  programs = {
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
    lf = let
      # Linux: xdg-open
      # macOS: open
      openCommand = if pkgs.stdenv.isLinux then "xdg-open" else "open";
    in {
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

      themes = {
        "catppuccin-${catppuccinTheme}" = builtins.readFile (
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "1g2r6j33f4zys853i1c5gnwcdbwb6xv5w6pazfdslxf69904lrg9";
          } + "/Catppuccin-${catppuccinTheme}.tmTheme"
        );
      };

      config = {
        theme = "catppuccin-${catppuccinTheme}";
      };
    };

    # `top` alternative
    # https://htop.dev/
    htop = {
      enable = true;
    };
  };
}





