# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

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

