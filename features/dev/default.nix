# Development related configurations
{ config, lib, ... }:
let
  cfg = config.features.dev;
in
{
  options = {
    features.dev = {
      enable = lib.mkEnableOption "Development";
    };
  };

  imports = [ ./lsp.nix ];

  config = {
    #  Runtime Executor (asdf-plugin compatible)
    # https://github.com/jdxcode/rtx
    programs.rtx = lib.mkIf cfg.enable {
      enable = true;
    };
  };

}
