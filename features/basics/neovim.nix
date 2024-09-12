{ config, pkgs, ... }: {
  config = {
    programs = {
      neovim = {
        enable = true;

        defaultEditor = true;

        extraLuaConfig = ''
          -- Enable fast Lua module loader
          vim.loader.enable()

          -- Set default tab size
          vim.opt.tabstop = 2

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

          -- Prevent stupid YAML "defaults" from increasing indent level on newline
          vim.api.nvim_create_autocmd(
            "Filetype",
            {
              pattern = { "yaml" },
              command = "setlocal indentkeys=",
            }
          )

          -- Prevent default zig plugin from automatically format on save
          -- https://github.com/ziglang/zig.vim/issues/51
          vim.g.zig_fmt_autosave = 0

          -- Configure Telescope and its plugins
          require("telescope").setup {
            pickers = {
              find_files = {
                theme = "dropdown",
                hidden = true,
              },
              live_grep = {
                theme = "dropdown",
                hidden = true,
              },
              buffers = {
                theme = "dropdown",
              },
              diagnostics = {
                theme = "dropdown",
              },
            },
            extensions = {
              file_browser = {
                theme = "dropdown",
                path = "%:p:h",
                dir_icon = "+",
                hijack_netrw = true,
                display_stat = false,
                create_from_prompt = false,
                hidden = {
                  file_browser = true,
                  folder_browser = true,
                },
              }
            }
          }
        '';

        plugins = with pkgs.vimPlugins; [
          plenary-nvim
          {
            plugin = telescope-nvim;
            type = "lua";
            config = ''
              local builtin = require("telescope.builtin")
              vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
              vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
              vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
              vim.keymap.set("n", "<leader>fd", function()
                builtin.diagnostics({
                  wrap_results = true,
                  line_width = "full",
                  bufnr = 0,
                })
              end, {})
            '';
          }
          {
            plugin = telescope-file-browser-nvim;
            type = "lua";
            config = ''
              vim.keymap.set("n", "<leader>fs", ":Telescope file_browser<CR>");
            '';
          }
          {
            plugin = indent-blankline-nvim;
            type = "lua";
            config = ''
              require("ibl").setup({
                scope = {
                  -- Turn off the fuckin' visual noise, level of bloat of this module is insane
                  enabled = false,
                },
              })

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
          {
            plugin = lualine-nvim;
            type = "lua";
            config = ''
              require("lualine").setup({
                options = {
                  icons_enabled = false,
                  section_separators = "",
                  component_separators = "",
                },
                sections = {
                  lualine_a = { "mode" },
                  lualine_b = { "diagnostics" },
                  lualine_c = {
                    {
                      "filename",
                      path = 1,
                    },
                  },
                  lualine_x = { "filetype" },
                  lualine_y = { "progress" },
                  lualine_z = { "location" },
                },
                inactive_sections = {
                  lualine_a = {},
                  lualine_b = { "diagnostics" },
                  lualine_c = {
                    {
                      "filename",
                      path = 1,
                    },
                  },
                  lualine_x = { "filetype" },
                  lualine_y = {},
                  lualine_z = {},
                },
              })
            '';
          }
        ];
      };
    };
  };
}
