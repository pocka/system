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
