-- Session Management
-- Auto-save and restore sessions per directory
return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        dir = vim.fn.stdpath("state") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" },
        pre_save = nil,
        save_empty = false,
    },
    keys = {
        { "<leader>qs", function() require("persistence").load() end, desc = "Restore session (cwd)" },
        { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
        { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
    init = function()
        -- Auto-load session if started without arguments
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
            callback = function()
                if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
                    require("persistence").load()
                end
            end,
            nested = true,
        })
    end,
}
