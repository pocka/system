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

{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.features.identity;
in
{
  options = {
    features.identity = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;

        description = ''
          Your name, prefebly publicly distinguishable.
        '';
      };

      email = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;

        description = ''
          Email address.
        '';
      };

      gpgSigningKeyId = lib.mkOption {
        type = lib.types.nullOr lib.types.nonEmptyStr;

        default = null;

        description = ''
          A key ID of a signing key (primary or subkey).
          This is a **key ID**, which is visible to public.
          Do not put key signature here.
        '';
      };
    };
  };

  config = {
    programs = {
      gpg = {
        enable = cfg.gpgSigningKeyId != null;
      };
    };

    services.gpg-agent = {
      enable = cfg.gpgSigningKeyId != null && pkgs.stdenv.isLinux;

      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;

      # 1day
      defaultCacheTtl = 86400;
      defaultCacheTtlSsh = 86400;

      # 30days
      maxCacheTtl = 2592000;
      maxCacheTtlSsh = 2592000;

      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
