{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: let
    # Catppuccin pallet, one of: "latte", "frappe", "macchiato", "mocha"
    catppuccinTheme = "mocha";

    # Pre-defined modules
    mods = {
      essentials = import ./essentials {
        inherit catppuccinTheme;
      };

      scm = import ./scm {
        username = "Shota FUJI";
        email = "pockawoooh@gmail.com";
        gpgKeyId = "5E5148973E291363";
      };

      wayland-de = import ./wayland-de {
        inherit catppuccinTheme;
      };

      webdev = ./webdev;

      macos = import ./macos {
        inherit catppuccinTheme;
      };
    };

    mkHomeConfiguration = {
      # Platform (e.g. x86_64-linux)
      system,
      # OS username
      username,
      # Modules to include
      modules ? [mods.essentials],
      # Timezone of the machine
      timezone ? "Asia/Tokyo",
    }: let
      isDarwin = (builtins.match ".*-darwin$" system) != null;
      homeDir =
        if isDarwin
        then "/Users"
        else "/home";
    in
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules =
          [
            {
              home = rec {
                inherit username;
                homeDirectory = "${homeDir}/${username}";
                stateVersion = "23.11";
                sessionVariables = {
                  TZ = timezone;
                };
              };

              # Turn off Home Manager news bs
              news.display = "silent";
            }
          ]
          ++ modules;
      };

    availableSystems = [
      "aarch64-darwin"
      "x86_64-linux"
    ];
  in {
    homeConfigurations = {
      dev-linux = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "pocka";
        modules = [
          mods.essentials
          mods.scm
          mods.webdev
          mods.wayland-de
        ];
      };

      pixelbook = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "pockawoooh";
        modules = [
          mods.essentials
          mods.scm
          mods.webdev
        ];
      };

      scm-server = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "pocka";
        modules = [
          mods.essentials
          mods.scm
        ];
      };

      mbp-m1 = mkHomeConfiguration {
        system = "aarch64-darwin";
        username = "pocka";
        modules = [
          mods.essentials
          mods.scm
          mods.webdev
          mods.macos
        ];
      };
    };

    formatter = builtins.listToAttrs (
      builtins.map (system: {
        name = system;
        value = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      })
      availableSystems
    );
  };
}
