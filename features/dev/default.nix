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
      # dev tools, env vars, task runner (asdf-plugin compatible)
      # https://github.com/jdx/mise
      mise.enable = true;

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

    home.packages = lib.mkIf cfg.enable [
      # a structural diff tool that understands syntax
      # https://difftastic.wilfred.me.uk/
      pkgs.difftastic
    ];
  };

}
