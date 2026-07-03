-- Obsidian-style in-buffer markdown rendering.
-- Renders headings, code blocks, lists, tables, callouts, links, checkboxes, etc.
-- inline so the buffer looks like the rendered preview while remaining editable.
return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "markdown.mdx", "mdx", "Avante", "codecompanion" },
    keys = {
        { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown Render" },
    },
    opts = {
        -- Render in normal mode; switch to raw text in insert/visual so editing is precise
        render_modes = { "n", "c", "t" },

        anti_conceal = {
            enabled = true,
        },

        heading = {
            enabled = true,
            sign = true,
            position = "overlay",
            icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
            width = "block",
            left_pad = 0,
            right_pad = 4,
            min_width = 60,
            border = false,
        },

        code = {
            enabled = true,
            sign = true,
            style = "full",
            position = "left",
            language_pad = 2,
            disable_background = { "diff" },
            width = "full",
            left_pad = 1,
            right_pad = 1,
            border = "thin",
            above = "▄",
            below = "▀",
        },

        bullet = {
            enabled = true,
            icons = { "●", "○", "◆", "◇" },
            left_pad = 0,
            right_pad = 1,
        },

        checkbox = {
            enabled = true,
            unchecked = { icon = "󰄱 " },
            checked = { icon = "󰱒 " },
            custom = {
                todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
            },
        },

        quote = {
            enabled = true,
            icon = "▎",
            repeat_linebreak = true,
        },

        pipe_table = {
            enabled = true,
            preset = "round",
            style = "full",
            cell = "padded",
            alignment_indicator = "━",
        },

        link = {
            enabled = true,
            image = "󰥶 ",
            email = "󰀓 ",
            hyperlink = "󰌹 ",
            wiki = { icon = "󱗖 ", highlight = "RenderMarkdownLink" },
        },

        callout = {
            note      = { raw = "[!NOTE]",      rendered = "󰋽 Note",      highlight = "RenderMarkdownInfo" },
            tip       = { raw = "[!TIP]",       rendered = "󰌶 Tip",       highlight = "RenderMarkdownSuccess" },
            important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
            warning   = { raw = "[!WARNING]",   rendered = "󰀪 Warning",   highlight = "RenderMarkdownWarn" },
            caution   = { raw = "[!CAUTION]",   rendered = "󰳦 Caution",   highlight = "RenderMarkdownError" },
        },

        sign = {
            enabled = true,
        },

        win_options = {
            -- Show full text where conceal would normally hide markup
            conceallevel = { default = vim.o.conceallevel, rendered = 2 },
            concealcursor = { default = vim.o.concealcursor, rendered = "" },
        },
    },
    config = function(_, opts)
        require("render-markdown").setup(opts)
        -- Treesitter parsers required for full rendering
        pcall(function()
            require("nvim-treesitter.install").ensure_installed({ "markdown", "markdown_inline" })
        end)
    end,
}
