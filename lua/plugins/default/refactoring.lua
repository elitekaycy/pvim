return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	lazy = false,
	config = function()
		require("refactoring").setup({

			prompt_func_return_type = {
				go = false,
				java = true,

				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			prompt_func_param_type = {
				go = false,
				java = true,

				cpp = false,
				c = false,
				h = false,
				hpp = false,
				cxx = false,
			},
			printf_statements = {},
			print_var_statements = {},
			show_success_message = true,
		})

		vim.keymap.set("x", "<leader>rf", function()
			require("refactoring").refactor("Extract Function To File")
		end)
		vim.keymap.set("x", "<leader>rv", function()
			require("refactoring").refactor("Extract Variable")
		end)
		vim.keymap.set("n", "<leader>rI", function()
			require("refactoring").refactor("Inline Function")
		end)
		vim.keymap.set({ "n", "x" }, "<leader>ri", function()
			require("refactoring").refactor("Inline Variable")
		end)

		vim.keymap.set("n", "<leader>rb", function()
			require("refactoring").refactor("Extract Block")
		end)
		vim.keymap.set("n", "<leader>rbf", function()
			require("refactoring").refactor("Extract Block To File")
		end)
	end,
}
