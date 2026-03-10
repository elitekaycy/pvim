return {
    "andreshazard/vim-freemarker",
    ft = "ftl",
    config = function()
        local ftl_telescope = require("utils.ftl_telescope")

        -- FTL-specific keybindings (note: <leader>fB to avoid conflict with telescope buffers)
        local ftl_group = vim.api.nvim_create_augroup("FTLConfig", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = ftl_group,
            pattern = "ftl",
            callback = function(args)
                local opts = { buffer = args.buf, noremap = true, silent = true }
                vim.keymap.set("n", "<leader>fi", ":call FTLIf()<CR>", opts)
                vim.keymap.set("n", "<leader>fl", ":call FTLList()<CR>", opts)
                vim.keymap.set("n", "<leader>fB", ":call FTLBigList()<CR>", opts)
                vim.keymap.set("n", "<leader>fs", ":call FTLSwitch()<CR>", opts)
                vim.keymap.set("n", "<leader>fa", ":call FTLAssign()<CR>", opts)
                vim.keymap.set("n", "<leader>ca", ftl_telescope.ftl_code_actions, opts)

                vim.opt_local.omnifunc = "htmlcomplete#CompleteTags"
                vim.opt_local.completeopt = "menuone,longest,preview"
            end,
        })
    end
}
