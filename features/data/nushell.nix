{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.features.data.enable {
    programs.nushell = {
      enable = lib.mkDefault true;

      configFile.text = ''
        $env.config = {
          show_banner: false
          edit_mode: vi
        }
      '';

      envFile.text = ''
      '';
    };
  };
}
