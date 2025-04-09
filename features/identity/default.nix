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

{ lib, pkgs, config, ... }:
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

      enableZshIntegration = config.programs.zsh.enable;

      # 1day
      defaultCacheTtl = 86400;
      defaultCacheTtlSsh = 86400;

      # 30days
      maxCacheTtl = 2592000;
      maxCacheTtlSsh = 2592000;

      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
