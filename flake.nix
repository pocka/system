{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , mac-app-util
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
          pkgs = nixpkgs.legacyPackages.${system};

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

                specialisation = {
                  dark.configuration = {
                    # One of: "latte", "frappe", "macchiato", "mocha"
                    themes.catppuccin.flavor = module.themes.catppuccin.flavor or "mocha";
                  };

                  light.configuration = {
                    themes.catppuccin.flavor = "latte";
                  };
                };

                home.packages = [
                  pkgs.home-manager
                  (pkgs.callPackage ./programs/specialise {
                    specialisations = pkgs.lib.attrsets.mapAttrsToList
                      (name: _: name)
                      specialisation;
                  })
                ];

                features = nixpkgs.lib.mkDefault {
                  identity = {
                    name = "Shota FUJI";
                    email = "pockawoooh@gmail.com";
                    gpgSigningKeyId = "5E5148973E291363";
                  };

                  data.enable = true;
                  scm.enable = true;

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

            wayland.windowManager.sway.config = {
              startup = [
                { command = "/usr/lib/policykit-1-pantheon/io.elementary.desktop.agent-polkit"; }
              ];

              output = {
                "HDMI-A-1" = {
                  scale = "1.5";
                };
              };
            };
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
    };
}
