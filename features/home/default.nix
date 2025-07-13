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
# Home Manager stuffs

{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.features.home;
in
{
  options.features.home = {
    username = lib.mkOption {
      type = lib.types.nonEmptyStr;

      description = ''
        System user name used to login to the machine.
      '';
    };

    timezone = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;

      default = null;

      description = ''
        Machine's timezone.

        Ideally this should be a mutable machine state considering it being variable property.
        However, in some environment or program couldn't pick up the value without explicitly specifiying in Nix config.

        This is to make very sure everything works.
      '';
    };

    locale = lib.mkOption {
      type = lib.types.nullOr lib.types.nonEmptyStr;

      default = null;

      description = ''
        Machine's locale (LC_ALL).

        e.g. `en_US.UTF-8`
      '';
    };
  };

  config =
    let
      homeDir = if pkgs.stdenv.isDarwin then "/Users" else "/home";
      username = cfg.username;
    in
    {
      home = {
        inherit username;

        homeDirectory = "${homeDir}/${username}";

        # `sessionVariables` does not accept `null` as an attribute value.
        # Need to manually filter out `null` values.
        sessionVariables = lib.attrsets.filterAttrs (name: value: value != null) {
          TZ = cfg.timezone;
          LC_ALL = cfg.locale;
        };
      };
    };
}
