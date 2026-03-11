-- CCC (Color Picker)
-- Pick and edit colors in your code
return {
    "uga-rosa/ccc.nvim",
    cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" },
    keys = {
        { "<leader>cp", "<cmd>CccPick<cr>", desc = "Color picker" },
        { "<leader>cc", "<cmd>CccConvert<cr>", desc = "Convert color format" },
        { "<leader>ch", "<cmd>CccHighlighterToggle<cr>", desc = "Toggle color highlight" },
    },
    opts = {
        -- Default color (when no color under cursor)
        default_color = "#000000",

        -- Bar characters
        bar_char = "█",
        point_char = "◇",

        -- Bar length
        bar_len = 30,

        -- Highlighter
        highlighter = {
            auto_enable = true,
            lsp = true,
            filetypes = {
                "css",
                "scss",
                "sass",
                "less",
                "html",
                "javascript",
                "javascriptreact",
                "typescript",
                "typescriptreact",
                "vue",
                "svelte",
                "lua",
            },
            excludes = {},
        },

        -- Recognize various formats
        recognize = {
            input = true,
            output = true,
        },

        -- Input/output modes
        inputs = {
            require("ccc").input.rgb,
            require("ccc").input.hsl,
            require("ccc").input.hwb,
            require("ccc").input.lab,
            require("ccc").input.lch,
            require("ccc").input.oklab,
            require("ccc").input.oklch,
            require("ccc").input.cmyk,
            require("ccc").input.hsluv,
            require("ccc").input.okhsl,
            require("ccc").input.hsv,
            require("ccc").input.okhsv,
            require("ccc").input.xyz,
        },

        outputs = {
            require("ccc").output.hex,
            require("ccc").output.hex_short,
            require("ccc").output.css_rgb,
            require("ccc").output.css_hsl,
            require("ccc").output.css_hwb,
            require("ccc").output.css_lab,
            require("ccc").output.css_lch,
            require("ccc").output.css_oklab,
            require("ccc").output.css_oklch,
            require("ccc").output.float,
        },

        -- Convert color under cursor
        convert = {
            { require("ccc").picker.hex, require("ccc").output.css_rgb },
            { require("ccc").picker.css_rgb, require("ccc").output.css_hsl },
            { require("ccc").picker.css_hsl, require("ccc").output.hex },
        },

        -- Picker window
        win_opts = {
            relative = "cursor",
            row = 1,
            col = 1,
            style = "minimal",
            border = "rounded",
        },

        -- Preserve original format when possible
        preserve = true,

        -- Mappings in picker
        mappings = {
            ["q"] = require("ccc").mapping.quit,
            ["<CR>"] = require("ccc").mapping.complete,
            ["i"] = require("ccc").mapping.toggle_input_mode,
            ["o"] = require("ccc").mapping.toggle_output_mode,
            ["g"] = require("ccc").mapping.toggle_prev_colors,
            ["a"] = require("ccc").mapping.toggle_alpha,
            ["L"] = require("ccc").mapping.increase1,
            ["H"] = require("ccc").mapping.decrease1,
            ["l"] = require("ccc").mapping.increase5,
            ["h"] = require("ccc").mapping.decrease5,
            ["<Right>"] = require("ccc").mapping.increase1,
            ["<Left>"] = require("ccc").mapping.decrease1,
            ["1"] = require("ccc").mapping.set0,
            ["0"] = require("ccc").mapping.set100,
        },
    },
    config = function(_, opts)
        require("ccc").setup(opts)
    end,
}
