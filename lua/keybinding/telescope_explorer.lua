vim.keymap.set("n", "<leader><leader>", function()
    require("telescope.builtin").find_files()
end, { desc = "Telescope find all files" })

vim.keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
end, { desc = "Telescope find files" })

vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })

vim.keymap.set("n", "<leader>fb", function()
    require("telescope.builtin").buffers()
end, { desc = "Telescope buffers" })

vim.keymap.set("n", "<leader>fh", function()
    require("telescope.builtin").help_tags()
end, { desc = "Telescope help tags" })

-- Search word under cursor across all files
vim.keymap.set("n", "<leader>fw", function()
    require("telescope.builtin").grep_string()
end, { desc = "Search word under cursor" })

-- Search in current buffer (fuzzy)
vim.keymap.set("n", "<leader>/", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Fuzzy search in buffer" })

-- Resume last search
vim.keymap.set("n", "<leader>fr", function()
    require("telescope.builtin").resume()
end, { desc = "Resume last search" })
