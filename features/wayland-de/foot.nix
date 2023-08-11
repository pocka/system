{ config, lib, pkgs, ... }: {
  programs =
    lib.mkIf config.features.wayland-de.enable {
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
            font = "monospace:size=10";
          };

          colors = {
            alpha = 0.9;
          };
        };
      };
    };
}

