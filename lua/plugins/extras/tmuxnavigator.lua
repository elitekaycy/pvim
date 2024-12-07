return {
	"christoomey/vim-tmux-navigator",
	config = function()
		-- Disable default key mappings
		vim.g.tmux_navigator_no_mappings = 1

		-- Set custom keybindings
		vim.api.nvim_set_keymap("n", "<C-h>", ":TmuxNavigateLeft<CR>", { noremap = true })
		vim.api.nvim_set_keymap("n", "<C-j>", ":TmuxNavigateDown<CR>", { noremap = true })
		vim.api.nvim_set_keymap("n", "<C-k>", ":TmuxNavigateUp<CR>", { noremap = true })
		vim.api.nvim_set_keymap("n", "<C-l>", ":TmuxNavigateRight<CR>", { noremap = true })
	end,
}
