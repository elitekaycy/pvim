vim.keymap.set(
    "n",
    "<leader>e",
    function()
        local api = require("nvim-tree.api")
        api.tree.toggle({
            find_file = true,
            focus = true
        })
    end,
    { noremap = true, silent = true, desc = "Toggle File Explorer" }
)

vim.cmd([[autocmd BufWinLeave NvimTree_* silent! NvimTreeClose]])
vim.keymap.set(
    "n",
    "<CR>",
    ":lua require'nvim-tree.api'.node.open.new_tab()<CR>",
    { noremap = true, silent = true, desc = "Open File in New Buffer" }
)
