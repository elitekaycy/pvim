-- Neogit
-- Magit-like git interface for Neovim
return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit" },
    keys = {
        { "<leader>gn", "<cmd>Neogit<cr>", desc = "Open Neogit" },
        { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
        { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
        { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit push" },
    },
    opts = {
        disable_signs = false,
        disable_hint = false,
        disable_context_highlighting = false,
        disable_commit_confirmation = false,
        auto_refresh = true,
        sort_branches = "-committerdate",
        kind = "tab",
        signs = {
            section = { "", "" },
            item = { "", "" },
            hunk = { "", "" },
        },
        integrations = {
            diffview = true,
            telescope = true,
        },
        sections = {
            untracked = {
                folded = false,
            },
            unstaged = {
                folded = false,
            },
            staged = {
                folded = false,
            },
            stashes = {
                folded = true,
            },
            unpulled = {
                folded = true,
            },
            unmerged = {
                folded = false,
            },
            recent = {
                folded = true,
            },
        },
        mappings = {
            status = {
                ["q"] = "Close",
                ["1"] = "Depth1",
                ["2"] = "Depth2",
                ["3"] = "Depth3",
                ["4"] = "Depth4",
                ["<tab>"] = "Toggle",
                ["s"] = "Stage",
                ["S"] = "StageUnstaged",
                ["u"] = "Unstage",
                ["U"] = "UnstageStaged",
                ["c"] = "CommitPopup",
                ["p"] = "PullPopup",
                ["P"] = "PushPopup",
                ["r"] = "RebasePopup",
                ["L"] = "LogPopup",
                ["?"] = "HelpPopup",
            },
        },
    },
}
