-- mini-completion.lua -- Setup mini.completion
--
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

require("mini.completion").setup({
	window = {
		info = { border = "single" },
		signature = { border = "single" },
	},
	lsp_completion = {
		snippet_insert = vim.snippet.expand,
	},
	fallback_action = function() end,
})

-- from :h mini-completion
local imap_expr = function(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true })
end
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

local keycode = vim.keycode
	or function(x)
		return vim.api.nvim_replace_termcodes(x, true, true, true)
	end
local keys = {
	["cr"] = keycode("<CR>"),
	["ctrl-y"] = keycode("<C-y>"),
	["ctrl-y_cr"] = keycode("<C-y><CR>"),
}

_G.cr_action = function()
	if vim.fn.pumvisible() ~= 0 then
		-- If popup is visible, confirm selected item or add new line otherwise
		local item_selected = vim.fn.complete_info()["selected"] ~= -1
		return item_selected and keys["ctrl-y"] or keys["ctrl-y_cr"]
	else
		-- If popup is not visible, use plain `<CR>`. You might want to customize
		-- according to other plugins. For example, to use 'mini.pairs', replace
		-- next line with `return require('mini.pairs').cr()`
		return keys["cr"]
	end
end

vim.keymap.set("i", "<CR>", "v:lua._G.cr_action()", { expr = true })
