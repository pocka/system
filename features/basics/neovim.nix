# Copyright 2023 Shota FUJI <pockawoooh@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

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

          -- Use ANSI colors
          vim.o.termguicolors = false

          -- Highlight current cursor line
          vim.o.cursorline = true

          -- Theme
          vim.cmd[[highlight! Comment ctermfg=7 cterm=italic]]
          vim.cmd[[highlight! Constant ctermfg=1 cterm=NONE]]
          vim.cmd[[highlight! Statement ctermfg=1]]
          vim.cmd[[highlight! Special ctermfg=3]]
          vim.cmd[[highlight! Function ctermfg=NONE cterm=bold]]
          vim.cmd[[highlight! NonText ctermfg=0]]
          vim.cmd[[highlight! LineNr ctermfg=8]]
          vim.cmd[[highlight! CursorLineNr ctermfg=7 cterm=bold]]
          vim.cmd[[highlight! Directory ctermfg=4]]
          vim.cmd[[highlight! Type ctermfg=6]]
          vim.cmd[[highlight! Operator ctermfg=7]]
          vim.cmd[[highlight! Identifier ctermfg=NONE]]
          vim.cmd[[highlight! Delimiter ctermfg=7]]
          vim.cmd[[highlight! @tag ctermfg=NONE cterm=italic]]
          vim.cmd[[highlight! @tag.builtin ctermfg=7 cterm=bold]]

          -- Prevent stupid CSS "defaults" from registering hyphen as a keyword
          vim.api.nvim_create_autocmd(
            "Filetype",
            {
              pattern = { "css", "astro" },
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

          -- Disable extremely ridiculous "recommended style" for Markdown files,
          -- which comes from upstream (Vim). This fucking opt-out option automatically
          -- sets indentation related properties, such as tabstop and expandtab, ignoring
          -- user provided values and editorconfig. This anti-accessibility option should
          -- be disabled, of course. Neovim update introduced this monster and I found this
          -- solution in: <https://github.com/neovim/neovim/issues/23011>
          vim.g.markdown_recommended_style = 0

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

              -- Open file browser on startup if no arguments provided
              vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                  if vim.fn.argv(0) == "" then
                    require("telescope").extensions.file_browser.file_browser()
                  end
                end,
              })
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
              local lualine_colors = {
                active_bg = 0,
                inactive_bg = 0,
                inactive_fg = 8,
              }

              require("lualine").setup({
                options = {
                  theme = {
                    normal = {
                      a = { bg = lualine_colors.active_bg, gui = "bold" },
                      b = { bg = lualine_colors.active_bg },
                      c = { bg = lualine_colors.active_bg },
                    },
                    insert = {
                      a = { bg = lualine_colors.active_bg, gui = "bold" },
                      b = { bg = lualine_colors.active_bg },
                      c = { bg = lualine_colors.active_bg },
                    },
                    visual = {
                      a = { bg = lualine_colors.active_bg, gui = "bold" },
                      b = { bg = lualine_colors.active_bg },
                      c = { bg = lualine_colors.active_bg },
                    },
                    replace = {
                      a = { bg = lualine_colors.active_bg, gui = "bold" },
                      b = { bg = lualine_colors.active_bg },
                      c = { bg = lualine_colors.active_bg },
                    },
                    command = {
                      a = { bg = lualine_colors.active_bg, gui = "bold" },
                      b = { bg = lualine_colors.active_bg },
                      c = { bg = lualine_colors.active_bg },
                    },
                    inactive = {
                      a = { fg = lualine_colors.inactive_fg, bg = lualine_colors.inactive_bg, gui = "bold" },
                      b = { fg = lualine_colors.inactive_fg, bg = lualine_colors.inactive_bg },
                      c = { fg = lualine_colors.inactive_fg, bg = lualine_colors.inactive_bg },
                    },
                  },
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
