-- lspconfig.lua -- LSP keybindings
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

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = "rounded" })
		end, { buffer = ev.buf })
	end,
})

-- Rename
-- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.rename()>
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, {})

-- Highlight a token under a cursor
-- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.document_highlight()>
vim.keymap.set("n", "<leader>lh", function()
	-- Previous highlights need to be manually cleared.
	vim.lsp.buf.clear_references()
	vim.lsp.buf.document_highlight()
end, {})

-- Go to definition
-- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.definition()>
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, {})

-- Clear LSP highlights
-- <https://neovim.io/doc/user/lsp.html#vim.lsp.buf.clear_references()>
vim.keymap.set("n", "<leader>lc", vim.lsp.buf.clear_references, {})
