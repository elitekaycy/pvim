local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local handlers = require("plugins.lsp.handlers")

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		print("lua server attached")
		handlers.setup()

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
	end,
})
