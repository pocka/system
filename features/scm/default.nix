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
  pkgs,
  lib,
  config,
  ...
}:
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
          if (config.features.identity.gpgSigningKeyId != null) then
            {
              key = config.features.identity.gpgSigningKeyId;
              signByDefault = true;
            }
          else
            null;

        extraConfig = {
          core = {
            editor = if config.programs.neovim.enable then "nvim" else "vim";
          };

          init = {
            defaultBranch = "master";
          };
        }
        // difftasticConfig;

        ignores =
          let
            # # Ignore all bazel-* symlinks. There is no full list since this can change
            # based on the name of the directory bazel is cloned into.
            bazel = [ "/bazel-*" ];

            # Swap file
            nvim = if config.programs.neovim.enable then [ ".*.swp" ] else [ ];

            # https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
            darwin =
              if pkgs.stdenv.isDarwin then
                [
                  ".DS_Store"
                  ".AppleDouble"
                  ".LSOverride"
                ]
              else
                [ ];
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
          diff-formatter = [
            "difft"
            "--color=always"
            "$left"
            "$right"
          ];
        };

        revsets = {
          log = "all()";
        };

        git = {
          private-commits = "description(regex:'\\[WIP\\]')";
        };

        aliases = {
          # JJ by default sets incorrect author date (when "a work started" instead of "authored",)
          # because how it works internally (updating a git commit.) This command is to workaround
          # that design flaw by manually mark author date, like "git commit".
          author = [
            "desc"
            "--no-edit"
            "--reset-author"
          ];
          au = [ "author" ];
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

          phases = [
            "unpackPhase"
            "installPhase"
          ];

          nativeBuildInputs = [ pkgs.installShellFiles ];

          installPhase = ''
            installShellCompletion --zsh --name _fossil tools/fossil-autocomplete.zsh
          '';
        }
      )
    ];
  };
}
