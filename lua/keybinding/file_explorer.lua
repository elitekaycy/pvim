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

local nvimtree_group = vim.api.nvim_create_augroup("PvimNvimTree", { clear = true })
vim.api.nvim_create_autocmd("BufWinLeave", {
    group = nvimtree_group,
    pattern = "NvimTree_*",
    command = "silent! NvimTreeClose",
})

-- Note: <CR> keymap for nvim-tree should be set in nvim-tree's on_attach, not globally
