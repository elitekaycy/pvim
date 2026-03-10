return {
    "goolord/alpha-nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

        -- PVIM ASCII Art Header
        dashboard.section.header.val = {
            "",
            "",
            "██████╗ ██╗   ██╗██╗███╗   ███╗",
            "██╔══██╗██║   ██║██║████╗ ████║",
            "██████╔╝██║   ██║██║██╔████╔██║",
            "██╔═══╝ ╚██╗ ██╔╝██║██║╚██╔╝██║",
            "██║      ╚████╔╝ ██║██║ ╚═╝ ██║",
            "╚═╝       ╚═══╝  ╚═╝╚═╝     ╚═╝",
            "",
            "      Personalized Vim IDE",
            "",
        }

        -- Menu buttons
        dashboard.section.buttons.val = {
            dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
            dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
            dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
            dashboard.button("p", "  Recent projects", ":Telescope projects <CR>"),
            dashboard.button("g", "  Find word", ":Telescope live_grep <CR>"),
            dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
            dashboard.button("u", "  Update plugins", ":Lazy update <CR>"),
            dashboard.button("q", "  Quit", ":qa<CR>"),
        }

        -- Footer with stats
        local function footer()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
        end

        dashboard.section.footer.val = footer()
        dashboard.section.footer.opts.hl = "Comment"
        dashboard.section.header.opts.hl = "AlphaHeader"
        dashboard.section.buttons.opts.hl = "AlphaButtons"

        -- Layout
        dashboard.config.layout = {
            { type = "padding", val = 2 },
            dashboard.section.header,
            { type = "padding", val = 2 },
            dashboard.section.buttons,
            { type = "padding", val = 1 },
            dashboard.section.footer,
        }

        alpha.setup(dashboard.config)

        -- Set header color
        vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7" })
        vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#9ece6a" })
    end,
}
