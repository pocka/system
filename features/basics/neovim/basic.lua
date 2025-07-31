-- Copyright 2025 Shota FUJI <pockawoooh@gmail.com>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
-- REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
-- INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
-- LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
-- OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
-- PERFORMANCE OF THIS SOFTWARE.
--
-- SPDX-License-Identifier: 0BSD

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
vim.cmd([[highlight! Comment ctermfg=7 cterm=italic]])
vim.cmd([[highlight! Constant ctermfg=1 cterm=NONE]])
vim.cmd([[highlight! Statement ctermfg=1]])
vim.cmd([[highlight! Special ctermfg=3]])
vim.cmd([[highlight! Function ctermfg=NONE cterm=bold]])
vim.cmd([[highlight! NonText ctermfg=0]])
vim.cmd([[highlight! LineNr ctermfg=8]])
vim.cmd([[highlight! CursorLineNr ctermfg=7 cterm=bold]])
vim.cmd([[highlight! Directory ctermfg=4]])
vim.cmd([[highlight! Type ctermfg=6]])
vim.cmd([[highlight! Operator ctermfg=7]])
vim.cmd([[highlight! Identifier ctermfg=NONE]])
vim.cmd([[highlight! Delimiter ctermfg=7]])
vim.cmd([[highlight! @tag ctermfg=NONE cterm=italic]])
vim.cmd([[highlight! @tag.builtin ctermfg=7 cterm=bold]])
vim.cmd([[highlight! Pmenu ctermfg=15 ctermbg=NONE cterm=reverse]])
vim.cmd([[highlight! PmenuSel ctermfg=0 ctermbg=15 cterm=bold]])
vim.cmd([[highlight! PmenuSbar ctermfg=NONE ctermbg=7 cterm=NONE]])
vim.cmd([[highlight! PmenuThumb ctermfg=NONE ctermbg=8 cterm=NONE]])

-- Prevent stupid CSS "defaults" from registering hyphen as a keyword
vim.api.nvim_create_autocmd("Filetype", {
	pattern = { "css", "astro" },
	command = "setlocal iskeyword-=-",
})

-- Prevent stupid YAML "defaults" from increasing indent level on newline
vim.api.nvim_create_autocmd("Filetype", {
	pattern = { "yaml" },
	command = "setlocal indentkeys=",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "xml" },
	command = "set indentexpr=",
})

vim.filetype.add({
	extension = {
		vapi = "vala",
	},
})

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
require("telescope").setup({
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
		},
	},
})
