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
