{ config, pkgs, ... }: {
  programs = {
    tmux = {
      keyMode = "vi";

      # Ctrl+t
      prefix = "C-t";

      # Automatically spawn a session if trying to attach and none are running.
      newSession = true;

      # Use 24 hour clock.
      # Because I'm not insane.
      clock24 = true;

      # Whether to enable mouse support.
      mouse = true;

      # Time in milliseconds for which tmux waits after an escape is input.
      # NOTE: Without this, there will be a lag after hitting ESC (e.g. exiting insert mode)
      # https://github.com/neovim/neovim/wiki/FAQ#esc-in-tmux-or-gnu-screen-is-delayed
      escapeTime = 10;

      # True Color options:
      # https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
      extraConfig = ''
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",$TERM:Tc"

        bind | split-window -hc "#{pane_current_path}"
        bind - split-window -vc "#{pane_current_path}"
        unbind '"'
        unbind %

        bind c new-window -c "#{pane_current_path}"

        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        unbind Up
        unbind Down
        unbind Left
        unbind Right

        set -g status-position bottom
      '';
    };
  };
}

