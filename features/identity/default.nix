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
