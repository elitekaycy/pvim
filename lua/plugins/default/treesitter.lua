return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-treesitter.configs").setup({
			-- Only install parsers you actually use (others install on-demand)
			ensure_installed = {
				"java",
				"typescript",
				"tsx",
				"javascript",
				"html",
				"css",
				"json",
				"lua",
				"vim",
				"vimdoc",
				"markdown",
				"markdown_inline",
				"yaml",
				"xml",
				"sql",
				"http",
				"bash",
				"go",
				"python",
				"rust",
				"c",
				"cpp",
			},
			sync_install = false,
			auto_install = true,  -- Install other parsers on-demand when opening files
			ignore_install = {},
			highlight = { enable = true },
			indent = { enable = true },
			modules = {},
		})
	end,
}
