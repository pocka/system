{
  config,
  pkgs,
  ...
}: {
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
      };

      initExtra = ''
        # Activate colors module in order to colourise prompt
        autoload -Uz colors
        colors

        # Branch character (for readability)
        CH_BRANCH=$'\ue0a0'

        function custom-prompt() {
          echo -e "

        %f%k%b''${1}%1d ''${vcs_info_msg_0_}%k%f%b
        %{$fg[black]%}%# %{$fg_no_bold[white]%}"
        }

        # VCS
        autoload -Uz vcs_info

        precmd () { vcs_info }

        zstyle ":vcs_info:git:*" check-for-changes true
        zstyle ":vcs_info:git:*" stagedstr "%{$fg[green]%}*"
        zstyle ":vcs_info:git:*" unstagedstr "%{$fg[red]%}*"
        zstyle ":vcs_info:*" formats "%{$fg[white]%}''${CH_BRANCH} %b%c%u%{$fg[white]%}"
        zstyle ":vcs_info:*" actionformats "[%b|%a]"

        function zle-line-init zle-keymap-select {
          case $KEYMAP in
            vicmd)
              PROMPT=$(custom-prompt "%{$fg[green]%}")
              ;;
            main|viins)
              PROMPT=$(custom-prompt "%{$fg[blue]%}")
              ;;
          esac
          zle reset-prompt
        }

        zle -N zle-line-init
        zle -N zle-keymap-select
      '';
    };
  };
}

