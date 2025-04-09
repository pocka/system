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
#
# ===
# Platform specifc configurations

{ config, lib, pkgs, ... }:
{
  config = {
    # https://github.com/NixOS/nix/issues/3616
    # Every macOS updates overwrite /etc/zshrc and that breaks Nix initialisation.
    # This is a workaround for it so that I no longer need to manually edit the file.
    # https://github.com/NixOS/nix/issues/3616#issuecomment-1655785404
    programs.zsh = lib.mkIf (pkgs.stdenv.isDarwin && config.programs.zsh.enable) {
      initExtraFirst = ''
        if [[ ! $(command -v nix) && -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
          source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        fi
      '';
    };

    xdg = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };

    # I'm not sure this changes behaviour in a meaningful way.
    targets.genericLinux = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
    };
  };
}
