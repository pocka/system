{catppuccinTheme}: {
  config,
  pkgs,
  ...
}: {
  programs = {
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
