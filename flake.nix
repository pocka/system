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
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nur
    , mac-app-util
    , nixgl
    ,
    }:
    let
      mkHomeConfiguration =
        {
          # Platform (e.g. x86_64-linux)
          system
        , # Machine specific module setting
          module ? { }
        , # Color theme
          theme ? ./themes/catppuccin
        }:
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              nur.overlays.default
              (import ./overlays/legit.nix)
              # Local packages
              (final: prev: {
                my-theme = prev.callPackage ./programs/theme { };
                my-waybar-text = prev.callPackage ./programs/waybar-text { };
              })
            ];
          };

          modules =
            [
              # Fix Home-Manager on MacOS cannot register GUI applications and Spotlight
              # won't find those applications.
              mac-app-util.homeManagerModules.default
              ./features
              ({ config, ... }: rec {
                # Turn off Home Manager news bs
                news.display = "silent";

                home.stateVersion = "23.11";

                # One of: "latte", "frappe", "macchiato", "mocha"
                themes.catppuccin.flavor = module.themes.catppuccin.flavor or "mocha";

                home.packages = [
                  pkgs.home-manager
                  (pkgs.callPackage ./programs/hm-clean { })
                ];

                features = nixpkgs.lib.mkDefault {
                  identity = {
                    name = "Shota FUJI";
                    email = "pockawoooh@gmail.com";
                    gpgSigningKeyId = "5E5148973E291363";
                  };

                  data.enable = true;
                  scm.enable = true;
                  syncthing.enable = true;

                  home = {
                    username = "pocka";
                    timezone = "Asia/Tokyo";
                    locale = "en_US.UTF-8";
                  };

                  dev = {
                    enable = true;

                    lsp = {
                      enable = true;

                      langs = with config.features.dev.lsp; [
                        elm
                        typescript
                        deno
                        go
                        css
                        html
                        zig
                        gleam
                        swift
                      ];
                    };
                  };

                  wayland-de = {
                    ime.enable = true;
                  };
                };
              })
              module
              theme
            ];
        };

      availableSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    in
    {
      homeConfigurations = {
        dev-linux = mkHomeConfiguration {
          system = "x86_64-linux";
          module = {
            features.wayland-de.enable = true;
            features.gui.enable = true;

            nixGL.packages = nixgl.packages;
            nixGL.defaultWrapper = "mesa";
            nixGL.installScripts = [ "mesa" ];

            features.wayland-de.niri.outputs = [
              { name = "HDMI-A-1"; scale = 1.4; }
            ];
          };
        };

        pixelbook = mkHomeConfiguration {
          system = "x86_64-linux";
          module = {
            features.home.username = "pockawoooh";

            # ChromeOS has neither tiling wm nor useful terminal emulator
            programs.tmux.enable = true;
          };
        };

        scm-server = mkHomeConfiguration {
          system = "x86_64-linux";
          module = {
            # Basically controlled over SSH
            programs.tmux.enable = true;

            # This server acts as a remote and only occasion commits are made on the server
            # is when fossil generates git repository on mirror (manual/automatic).
            features.identity.gpgSigningKeyId = null;

            features.dev.enable = false;

            features.scm-server.enable = true;
          };
        };

        mbp-m1 = mkHomeConfiguration {
          system = "aarch64-darwin";
          module = {
            features.gui.enable = true;
          };
        };

        macmini-m1 = mkHomeConfiguration {
          system = "aarch64-darwin";
          module = {
            features.gui.enable = true;
          };
        };
      };

      formatter = builtins.listToAttrs (
        builtins.map
          (system: {
            name = system;
            value = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
          })
          availableSystems
      );

      devShell = builtins.listToAttrs (
        builtins.map
          (system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              name = system;
              value =
                pkgs.mkShell {
                  packages = with pkgs; [
                    sunwait
                    tzdata
                    glib
                    zig
                    go
                  ];
                };
            }
          )
          availableSystems
      );
    };
}
