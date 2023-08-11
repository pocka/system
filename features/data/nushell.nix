{ config, lib, pkgs, ... }:
let
  cfg = config.features.data.nushell;

  colorGroup = lib.types.attrsOf (lib.types.either lib.types.nonEmptyStr colorGroup);

  serializeGroup = g:
    let
      lines = lib.attrsets.mapAttrsToList
        (name: colorOrSubGroup:
          "${name}: ${if (builtins.isString colorOrSubGroup) then "\"${colorOrSubGroup}\"" else (serializeGroup colorOrSubGroup)}"
        )
        g;
    in
    "{ ${lib.strings.concatStringsSep " " lines} }";
in
{
  options = {
    features.data.nushell.colorConfig = lib.mkOption {
      description = ''
        Nushell color config object.

        See https://www.nushell.sh/book/coloring_and_theming.html#theming for details.
      '';

      type = colorGroup;

      default = { };
    };
  };

  config = lib.mkIf config.features.data.enable {
    programs.nushell = {
      enable = lib.mkDefault true;

      configFile.text = ''
        $env.config = {
          show_banner: false
          color_config: ${serializeGroup cfg.colorConfig}
          edit_mode: vi
          ls: {
            use_ls_colors: true
          }
        }
      '';

      envFile.text = ''
      '';
    };
  };
}
