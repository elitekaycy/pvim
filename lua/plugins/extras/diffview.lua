-- Diffview
-- Better git diff UI with side-by-side view
return {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
        { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Branch history" },
        { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = {
        diff_binaries = false,
        enhanced_diff_hl = true,
        use_icons = true,
        icons = {
            folder_closed = "",
            folder_open = "",
        },
        signs = {
            fold_closed = "",
            fold_open = "",
            done = "✓",
        },
        view = {
            default = {
                layout = "diff2_horizontal",
                winbar_info = false,
            },
            merge_tool = {
                layout = "diff3_horizontal",
                disable_diagnostics = true,
            },
            file_history = {
                layout = "diff2_horizontal",
                winbar_info = false,
            },
        },
        file_panel = {
            listing_style = "tree",
            tree_options = {
                flatten_dirs = true,
                folder_statuses = "only_folded",
            },
            win_config = {
                position = "left",
                width = 35,
            },
        },
        keymaps = {
            view = {
                { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle file panel" } },
                { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            },
            file_panel = {
                { "n", "j", "<cmd>lua require('diffview.actions').next_entry()<cr>", { desc = "Next entry" } },
                { "n", "k", "<cmd>lua require('diffview.actions').prev_entry()<cr>", { desc = "Prev entry" } },
                { "n", "<cr>", "<cmd>lua require('diffview.actions').select_entry()<cr>", { desc = "Open diff" } },
                { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            },
        },
    },
}
