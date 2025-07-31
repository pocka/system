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

require("ibl").setup({
	scope = {
		-- Turn off the fuckin' visual noise, level of bloat of this module is insane
		enabled = false,
	},
})

-- Disable stupid fake indentations
local hooks = require("ibl.hooks")
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
