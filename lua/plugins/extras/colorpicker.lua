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
    config = function()
        local ccc = require("ccc")

        ccc.setup({
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
                ccc.input.rgb,
                ccc.input.hsl,
                ccc.input.hwb,
                ccc.input.lab,
                ccc.input.lch,
                ccc.input.oklab,
                ccc.input.oklch,
                ccc.input.cmyk,
                ccc.input.hsluv,
                ccc.input.okhsl,
                ccc.input.hsv,
                ccc.input.okhsv,
                ccc.input.xyz,
            },

            outputs = {
                ccc.output.hex,
                ccc.output.hex_short,
                ccc.output.css_rgb,
                ccc.output.css_hsl,
                ccc.output.css_hwb,
                ccc.output.css_lab,
                ccc.output.css_lch,
                ccc.output.css_oklab,
                ccc.output.css_oklch,
                ccc.output.float,
            },

            -- Convert color under cursor
            convert = {
                { ccc.picker.hex, ccc.output.css_rgb },
                { ccc.picker.css_rgb, ccc.output.css_hsl },
                { ccc.picker.css_hsl, ccc.output.hex },
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
                ["q"] = ccc.mapping.quit,
                ["<CR>"] = ccc.mapping.complete,
                ["i"] = ccc.mapping.toggle_input_mode,
                ["o"] = ccc.mapping.toggle_output_mode,
                ["g"] = ccc.mapping.toggle_prev_colors,
                ["a"] = ccc.mapping.toggle_alpha,
                ["L"] = ccc.mapping.increase1,
                ["H"] = ccc.mapping.decrease1,
                ["l"] = ccc.mapping.increase5,
                ["h"] = ccc.mapping.decrease5,
                ["<Right>"] = ccc.mapping.increase1,
                ["<Left>"] = ccc.mapping.decrease1,
                ["1"] = ccc.mapping.set0,
                ["0"] = ccc.mapping.set100,
            },
        })
    end,
}
