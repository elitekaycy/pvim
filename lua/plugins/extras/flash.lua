-- Flash.nvim
-- Navigate code with search labels, enhanced f/t motions
return {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
        { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
        { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
        { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
        { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
        { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash in search" },
    },
    opts = {
        -- Labels for jump targets
        labels = "asdfghjklqwertyuiopzxcvbnm",

        search = {
            -- Search matches across all windows
            multi_window = true,
            -- Search direction
            forward = true,
            -- Wrap around
            wrap = true,
            -- Regex or exact
            mode = "exact",
            -- Incremental search
            incremental = true,
        },

        jump = {
            -- Save location in jumplist
            jumplist = true,
            -- Jump position
            pos = "start",
            -- Clear highlight after jump
            nohlsearch = true,
            -- Auto-jump when there's only one match
            autojump = false,
        },

        label = {
            -- Show labels as uppercase
            uppercase = true,
            -- Exclude existing matches from labels
            exclude = "",
            -- Minimum pattern length for labels
            min_pattern_length = 0,
            -- Use rainbow highlights for labels
            rainbow = {
                enabled = false,
            },
        },

        -- Enhanced f/t/F/T motions
        modes = {
            search = {
                enabled = true,  -- Integrate with / search
                highlight = { backdrop = false },
            },
            char = {
                enabled = true,
                highlight = { backdrop = true },
                jump = { register = false },
                multi_line = false,
                keys = { "f", "F", "t", "T", ";", "," },
            },
            treesitter = {
                labels = "asdfghjklqwertyuiopzxcvbnm",
                jump = { pos = "range" },
                search = { incremental = false },
                highlight = {
                    backdrop = false,
                    matches = false,
                },
            },
        },

        -- Highlight config
        highlight = {
            backdrop = true,
            matches = true,
            priority = 5000,
            groups = {
                match = "FlashMatch",
                current = "FlashCurrent",
                backdrop = "FlashBackdrop",
                label = "FlashLabel",
            },
        },
    },
}
