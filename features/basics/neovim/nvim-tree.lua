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

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeFindFileToggle<cr>", {
	silent = true,
	noremap = true,
})

local function tree_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return {
			desc = "nvim-tree: " .. desc,
			buffer = bufnr,
			noremap = true,
			silent = true,
			nowait = true,
		}
	end

	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close"))
	vim.keymap.set("n", "l", api.node.open.edit, opts("Edit or open"))
	vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "H", api.node.open.horizontal, opts("Horizontal split open"))
	vim.keymap.set("n", "V", api.node.open.vertical, opts("Vertical split open"))

	-- Modification key bindings, similar to ones of telescope-file-browser
	vim.keymap.set("n", "y", api.fs.copy.node, opts("Copy"))
	vim.keymap.set("n", "p", api.fs.paste, opts("Paste"))
	vim.keymap.set("n", "r", api.fs.rename_full, opts("Rename"))
	vim.keymap.set("n", "d", api.fs.remove, opts("Delete"))
	vim.keymap.set("n", "c", api.fs.create, opts("Create"))
end

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	on_attach = tree_on_attach,
	git = {
		enable = false,
	},
})
