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

