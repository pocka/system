# Configurations for data-related tasks: inspect, modify, etc...
{ config, lib, pkgs, ... }:
{
  options = {
    features.data.enable = lib.mkEnableOption "Data";
  };

  imports = [ ./nushell.nix ];

  config = lib.mkIf config.features.data.enable {
    home.packages = with pkgs; [
      # An advanced calculator library (`qalc` command)
      # https://qalculate.github.io/
      libqalculate
    ];

    programs = {
      # JSON view/query tool
      # https://github.com/jqlang/jq
      jq = {
        enable = true;
      };
    };
  };
}
