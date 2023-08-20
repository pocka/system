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
    programs.git = {
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
      };

      ignores =
        let
          # Swap file
          nvim = if config.programs.neovim.enable then [ ".*.swp" ] else [ ];

          # https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
          darwin =
            if pkgs.stdenv.isDarwin
            then [
              ".DS_Store"
              ".AppleDouble"
              ".LSOverride"
              "Icon"
            ]
            else [ ];
        in
        nvim ++ darwin;
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
