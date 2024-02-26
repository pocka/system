# Development related configurations
{ config, lib, pkgs, ... }:
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
    programs = lib.mkIf cfg.enable {
      #  Runtime Executor (asdf-plugin compatible)
      # https://github.com/jdxcode/rtx
      rtx.enable = true;

      neovim = lib.mkIf config.programs.neovim.enable {
        plugins = with pkgs.vimPlugins; [
          {
            plugin = nvim-treesitter.withAllGrammars;

            type = "lua";

            config = ''
              require("nvim-treesitter.configs").setup {
                auto_install = false,
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = false,
                },
              }
            '';
          }
        ];
      };
    };
  };

}
