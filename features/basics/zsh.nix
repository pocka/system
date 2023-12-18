{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.features.basics.zsh;
in
{
  options = {
    features.basics.zsh.theme = {
      text = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "%{$fg[white]%}";
      };

      vi.insert = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "%{$fg[blue]%}";
      };

      vi.normal = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "%{$fg[green]%}";
      };

      vcs = {
        info = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "%{$fg[white]%}";
        };

        staged = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "%{$fg[green]%}";
        };

        unstaged = lib.mkOption {
          type = lib.types.nonEmptyStr;
          default = "%{$fg[red]%}";
        };
      };

      symbol = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "%{$fg[black]%}";
      };
    };
  };

  config = {
    programs = {
      zsh = {
        enable = true;

        # The default base keymap to use.
        defaultKeymap = "viins";

        # Enable zsh completion. Don’t forget to add
        enableCompletion = true;

        # Options related to commands history configuration.
        history = {
          # Do not enter command lines into the history list if they are duplicates of the previous event.
          ignoreDups = true;

          # Save timestamp into the history file.
          extended = true;

          # Number of history lines to keep.
          size = 1000;

          # Share command history between zsh sessions.
          share = false;
        };

        sessionVariables = {
          # Insert space between completed string and ampersand or pipe
          ZLE_SPACE_SUFFIX_CHARS = "&|";
        };

        initExtra = with cfg.theme; ''
          # Activate colors module in order to colourise prompt
          autoload -Uz colors
          colors

          # Branch character (for readability)
          CH_BRANCH=$'\ue0a0'

          function custom-prompt() {
            echo -e "

          %f%k%b''${1}%1d ''${vcs_info_msg_0_}%k%f%b
          ${symbol}%# ${text}"
          }

          # VCS
          autoload -Uz vcs_info

          precmd () { vcs_info }

          zstyle ":vcs_info:git:*" check-for-changes true
          zstyle ":vcs_info:git:*" stagedstr "${vcs.staged}*"
          zstyle ":vcs_info:git:*" unstagedstr "${vcs.unstaged}*"
          zstyle ":vcs_info:*" formats "${vcs.info}''${CH_BRANCH} %b%c%u${text}"
          zstyle ":vcs_info:*" actionformats "[%b|%a]"

          function zle-line-init zle-keymap-select {
            case $KEYMAP in
              vicmd)
                PROMPT=$(custom-prompt "${vi.normal}")
                ;;
              main|viins)
                PROMPT=$(custom-prompt "${vi.insert}")
                ;;
            esac
            zle reset-prompt
          }

          zle -N zle-line-init
          zle -N zle-keymap-select
        '';
      };
    };
  };
}

