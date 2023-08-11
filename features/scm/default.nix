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

    home.packages = [ pkgs.fossil ];
  };
}
