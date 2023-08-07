{
  username,
  email,
  gpgKeyId,
}: {
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    git = {
      enable = true;

      userName = username;
      userEmail = email;

      # Enable signing when key ID is provided
      signing = lib.mkIf (gpgKeyId != null) {
        key = gpgKeyId;
        signByDefault = true;
      };

      extraConfig = {
        core = {
          editor = "nvim";
        };

        init = {
          defaultBranch = "master";
        };
      };

      ignores = [
        # vim swap file
        ".*.swp"

        # macOS junk
        # https://github.com/github/gitignore/blob/main/Global/macOS.gitignore
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "Icon"
      ];
    };
  };

  services = {
    gpg-agent = {
      enable = true;

      enableZshIntegration = true;

      # 1day
      defaultCacheTtl = 86400;
      defaultCacheTtlSsh = 86400;

      # 30days
      maxCacheTtl = 2592000;
      maxCacheTtlSsh = 2592000;
    };
  };
}
