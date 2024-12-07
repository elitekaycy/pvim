-- Keybinding setup
vim.keymap.set(
	"n",
	"<leader>e",
	":NvimTreeToggle<CR>",
	{ noremap = true, silent = true, desc = "Toggle File Explorer" }
)

-- Automatically focus on nvim-tree when opened and defocus when closed
vim.cmd([[autocmd BufWinEnter NvimTree_* silent! NvimTreeFocus]]) -- Focus on tree when opening
vim.cmd([[autocmd BufWinLeave NvimTree_* silent! NvimTreeClose]]) -- Close and defocus when leaving

-- Open file in a new buffer window
vim.keymap.set(
	"n",
	"<CR>",
	":lua require'nvim-tree.api'.node.open.new_tab()<CR>",
	{ noremap = true, silent = true, desc = "Open File in New Buffer" }
)
