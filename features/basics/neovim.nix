{ config, pkgs, ... }: {
  config = {
    programs = {
      neovim = {
        enable = true;

        defaultEditor = true;

        extraLuaConfig = ''
          -- Display absolute line numbers
          vim.wo.number = true

          -- Disable insane mouse hijacking
          vim.opt.mouse = ""

          -- Prevent stupid CSS "defaults" from registering hyphen as a keyword
          vim.api.nvim_create_autocmd(
            "Filetype",
            {
              pattern = { "css" },
              command = "setlocal iskeyword-=-",
            }
          )
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
                  git_ignored = false,
                },
              })
            '';
          }
          {
            plugin = indent-blankline-nvim;
            type = "lua";
            config = ''
              require("ibl").setup()

              -- Disable stupid fake indentations
              local hooks = require "ibl.hooks"
              hooks.register(hooks.type.VIRTUAL_TEXT, function(_, bufnr, row, virt_text)
                local cfg = require("ibl.config").get_config(bufnr)
                local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
                  if line == "" then
                    for _, v in ipairs(virt_text) do
                      if v[1] == cfg.indent.char then
                        v[1] = ""
                      end
                    end
                  end
                  return virt_text
              end)
            '';
          }
        ];
      };
    };
  };
}
