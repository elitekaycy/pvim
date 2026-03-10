vim.g.mapleader = " "
vim.opt.termguicolors = true

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<C-s>", ":w<CR>", opts)
map("n", "<C-q>", ":q<CR>", opts)

-- Window navigation handled by tmuxnavigator plugin (lua/plugins/extras/tmuxnavigator.lua)
