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

{ pkgs, lib, config, ... }:
let
  cfg = config.features.scm;
in
{
  options = {
    features.scm = {
      enable = lib.mkEnableOption "SCM";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git =
      let
        difftasticConfig =
          if config.features.dev.enable then
            {
              # https://difftastic.wilfred.me.uk/git.html
              diff = {
                tool = "difftastic";
              };

              difftool = {
                prompt = false;
              };

              "difftool \"difftastic\"" = {
                cmd = ''difft "$LOCAL" "$REMOTE"'';
              };

              pager = {
                difftool = true;
              };
            }
          else
            { };
      in
      {
        enable = true;

        userName = config.features.identity.name;
        userEmail = config.features.identity.email;

        signing =
          if (config.features.identity.gpgSigningKeyId != null) then {
            key = config.features.identity.gpgSigningKeyId;
            signByDefault = true;
          } else null;

        extraConfig = {
          core = {
            editor = if config.programs.neovim.enable then "nvim" else "vim";
          };

          init = {
            defaultBranch = "master";
          };
        } // difftasticConfig;

        ignores =
          let
            # # Ignore all bazel-* symlinks. There is no full list since this can change
            # based on the name of the directory bazel is cloned into.
            bazel = [ "/bazel-*" ];

            # Swap file
            nvim = if config.programs.neovim.enable then [ ".*.swp" ] else [ ];

            # https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
            darwin =
              if pkgs.stdenv.isDarwin
              then [
                ".DS_Store"
                ".AppleDouble"
                ".LSOverride"
              ]
              else [ ];
          in
          nvim ++ darwin ++ bazel;
      };

    # https://github.com/martinvonz/jj
    programs.jujutsu = {
      enable = true;

      settings = {
        user = {
          name = config.features.identity.name;
          email = config.features.identity.email;
        };

        signing = lib.mkIf (config.features.identity.gpgSigningKeyId != null) {
          behavior = "own";
          backend = "gpg";
          key = config.features.identity.gpgSigningKeyId;
        };

        ui = lib.mkIf config.features.dev.enable {
          diff = {
            tool = [ "difft" "--color=always" "$left" "$right" ];
          };
        };

        revsets = {
          log = "all()";
        };

        git = {
          private-commits = "description(regex:'\\[WIP\\]')";
        };
      };
    };

    home.packages = [
      pkgs.fossil
      (
        # Fossil derivation in Nixpkgs install bash completion only, while Fossil provides zsh's one too.
        # Creating a new derivation is so much effective compared to using `lib.overrideAttrs` because
        # of build cache.
        pkgs.stdenv.mkDerivation {
          pname = "fossil-zsh-completion";
          version = pkgs.fossil.version;

          src = pkgs.fossil.src;

          phases = [ "unpackPhase" "installPhase" ];

          nativeBuildInputs = [ pkgs.installShellFiles ];

          installPhase = ''
            installShellCompletion --zsh --name _fossil tools/fossil-autocomplete.zsh
          '';
        }
      )
    ];
  };
}
