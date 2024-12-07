return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"mfussenegger/nvim-jdtls",
	},
	config = function()
		require("mason").setup()

		require("mason-lspconfig").setup({
			ensure_installed = {
				"jdtls", -- Java language server
				"lua_ls", -- Example: Lua language server
				"ts_ls", -- Example: TypeScript language server
			},
			automatic_installation = true,
		})

		-- require("plugins.lsp.servers.typescript")
		-- require("plugins.lsp.servers.java")
		-- require("plugins.lsp.servers.lua")

		local lsp_servers_dir = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"
		for _, file in ipairs(vim.fn.readdir(lsp_servers_dir)) do
			if file:match("%.lua$") then
				local module_name = file:gsub("%.lua$", "")
				require("plugins.lsp.servers." .. module_name)
			end
		end
	end,
}
