-- Zen Mode
-- Distraction-free coding
return {
    {
        "folke/zen-mode.nvim",
        cmd = "ZenMode",
        keys = {
            { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
        },
        opts = {
            window = {
                backdrop = 0.95,
                width = 120,
                height = 1,
                options = {
                    signcolumn = "no",
                    number = false,
                    relativenumber = false,
                    cursorline = false,
                    cursorcolumn = false,
                    foldcolumn = "0",
                    list = false,
                },
            },
            plugins = {
                options = {
                    enabled = true,
                    ruler = false,
                    showcmd = false,
                    laststatus = 0,
                },
                twilight = { enabled = true },
                gitsigns = { enabled = false },
                tmux = { enabled = true },
                kitty = {
                    enabled = false,
                    font = "+4",
                },
            },
            on_open = function()
                vim.cmd("IBLDisable")
            end,
            on_close = function()
                vim.cmd("IBLEnable")
            end,
        },
    },
    {
        "folke/twilight.nvim",
        cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
        keys = {
            { "<leader>tw", "<cmd>Twilight<cr>", desc = "Toggle Twilight" },
        },
        opts = {
            dimming = {
                alpha = 0.25,
                color = { "Normal", "#ffffff" },
                term_bg = "#000000",
                inactive = false,
            },
            context = 10,
            treesitter = true,
            expand = {
                "function",
                "method",
                "table",
                "if_statement",
            },
        },
    },
}
