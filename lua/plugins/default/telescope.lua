return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"aznhe21/actions-preview.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"ThePrimeagen/refactoring.nvim",
	},
	config = function()
		require("telescope").setup({
			extensions = {
				lsp_actions = {
				},
			},
			defaults = {
				file_ignore_patterns = { "node_modules", ".git" },
				mappings = {
					i = {
						["<C-u>"] = false,
						["<C-d>"] = false,
					},
				},
			},
		})
		require("telescope").load_extension("ui-select")
		require("telescope").load_extension("refactoring")

		vim.keymap.set({ "n", "x" }, "<leader>rr", function()
			require("telescope").extensions.refactoring.refactors()
		end)
	end,
}
