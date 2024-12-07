-- Buffer Navigation Mappings
vim.api.nvim_set_keymap("n", "<S-h>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-l>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })

-- Vertical Split
vim.api.nvim_set_keymap("n", "<S-v>", ":vsplit<CR>", { noremap = true, silent = true })

-- Close Buffer with Leader + bd
vim.api.nvim_set_keymap("n", "<leader>bd", ":bdelete<CR>", { noremap = true, silent = true })
