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
# Home Manager stuffs

{ pkgs, lib, config, ... }:
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
        sessionVariables = lib.attrsets.filterAttrs
          (name: value: value != null)
          {
            TZ = cfg.timezone;
            LC_ALL = cfg.locale;
          };
      };
    };
}
