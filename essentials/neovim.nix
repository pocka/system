{catppuccinTheme}: {
  config,
  pkgs,
  ...
}: {
  programs = {
    neovim = {
      enable = true;

      defaultEditor = true;

      extraLuaConfig = ''
        -- Display absolute line numbers
        vim.wo.number = true
      '';

      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-tree-lua;
          type = "lua";
          config = ''
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
              renderer = {
                icons = {
                  show = {
                    file = false,
                    folder = false,
                    folder_arrow = false,
                    git = false,
                    modified = false,
                  },
                },
              },
              filters = {
                custom = {
                  -- Fossil checkout state file
                  "^\\.fslckout",
                },
              },
            })
          '';
        }
        {
          plugin = indent-blankline-nvim;
          type = "lua";
          config = ''
            require("indent_blankline").setup({
              -- Without those set, the plugin displays fake indentation
              char_blankline = "",
              space_char_blankline = "",
            })
          '';
        }
        {
          plugin = catppuccin-nvim;
          type = "lua";
          config = ''
            vim.o.termguicolors = true

            require("catppuccin").setup({
              flavour = "${catppuccinTheme}",
              transparent_background = true,
              integrations = {
                indent_blankline = {
                  enabled = true,
                },
                cmp = true,
                lsp_trouble = true,
              },
            })

            vim.cmd.colorscheme "catppuccin"
          '';
        }
      ];
    };
  };
}
