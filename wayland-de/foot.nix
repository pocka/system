{catppuccinTheme}: {
  config,
  pkgs,
  ...
}: {
  programs = let
    # Config file of catppuccin/foot is ini file: Nix can't parse that.
    # To workaround, manually fetch palette JSON and use its token.
    catppuccinPalette =
      (builtins.fromJSON (builtins.readFile (
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "palette";
          rev = "205dd54c6158b7648621cf9fd00e91f03888ce7e";
          sha256 = "y14fd8lvnG9hNY6CRU0JgxWouexEw91aIEMkr1NaM/4=";
        }
        + "/palette.json"
      )))
      ."${catppuccinTheme}";

    fg = builtins.substring 1 6 catppuccinPalette.surface0.hex;
    bg = builtins.substring 1 6 catppuccinPalette.text.hex;
  in {
    zsh = {
      # Let Zsh tell Foot a current working directory
      # https://codeberg.org/dnkl/foot/wiki#user-content-spawning-new-terminal-instances-in-the-current-working-directory
      initExtra = ''
        function osc7-pwd() {
            emulate -L zsh # also sets localoptions for us
            setopt extendedglob
            local LC_ALL=C
            printf '\e]7;file://%s%s\e\' $HOST ''${PWD//(#m)([^@-Za-z&-;_~])/%''${(l:2::0:)$(([##16]#MATCH))}}
        }

        function chpwd-osc7-pwd() {
            (( ZSH_SUBSHELL )) || osc7-pwd
        }
        autoload -Uz add-zsh-hook
        add-zsh-hook -Uz chpwd chpwd-osc7-pwd
      '';
    };

    # A fast, lightweight and minimalistic Wayland terminal emulator
    # https://codeberg.org/dnkl/foot
    foot = {
      enable = true;

      server.enable = true;

      settings = {
        main = {
          include = "${config.xdg.configHome}/foot/theme.conf";

          font = "monospace:size=10";
        };

        cursor = {
          # Foot by default invert fg/bg for cursor. However, this makes
          # cursor on indent_blankline's indent char/spaces barely visible.
          color = "${fg} ${bg}";
        };

        colors = {
          alpha = 0.9;
        };
      };
    };
  };

  xdg = {
    configFile."foot/theme.conf" = {
      text = builtins.readFile (
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "foot";
          rev = "009cd57bd3491c65bb718a269951719f94224eb7";
          sha256 = "0f0r8d4rn54gibrzfhiy4yr8bi7c8j18ggp1y9lyidc1dmy9kvw0";
        }
        + "/catppuccin-${catppuccinTheme}.conf"
      );
    };
  };
}
