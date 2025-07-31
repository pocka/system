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
				a = {
					fg = lualine_colors.inactive_fg,
					bg = lualine_colors.inactive_bg,
					gui = "bold",
				},
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
