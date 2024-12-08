local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local handlers = require("plugins.lsp.handlers")
local codelens = require("utils.codelens")

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		print("lua server attached")
		handlers.setup()
        codelens.on_attach(client, bufnr)

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run CodeLens" })

	end,
})
