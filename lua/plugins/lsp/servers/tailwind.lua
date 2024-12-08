local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.tailwindcss.setup({
	capabilities = capabilities,
	settings = {
		tailwindCSS = {
			experimental = {
				classRegex = "([\\w-/:]+)",
			},
			lint = {
				cssConflict = "warning",
			},
		},
	},
})
