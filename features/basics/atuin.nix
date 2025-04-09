# Copyright 2024 Shota FUJI <pockawoooh@gmail.com>
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
    # Replacement for a shell history which records additional commands context
    atuin = {
      enable = true;

      enableBashIntegration = false;
      enableFishIntegration = false;

      enableNushellIntegration = true;
      enableZshIntegration = true;

      settings = {
        auto_sync = false;

        show_preview = true;

        keymap_mode = "vim-normal";

        filter_mode = "directory";

        filter_mode_shell_up_key_binding = "session";

        update_check = false;
      };
    };
  };
}
