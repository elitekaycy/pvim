return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    config = function()
        require("noice").setup({
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = false,
                command_palette = false,
                long_message_to_split = false,
                inc_rename = false,
            },

            messages = {
                enabled = true,
                view = "notify",
                view_error = "notify",
                view_warn = "notify",
                view_history = "messages",
                view_search = "virtualtext",
            },

            routes = {
                {
                    filter = {
                        event = "lsp",
                        kind = "progress",
                        cond = function(message)
                            local client = vim.tbl_get(message.opts, "progress", "client")
                            return client == "lua_ls"
                        end,
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        kind = "search_count",
                    },
                    view = "notify",
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        kind = "",
                        find = "written",
                    },
                    view = "notify",
                    opts = { skip = true },
                },
            },
            notify = {
                enabled = true,
                view = "mini",   -- Compact view
                opts = {
                    position = { -- Bottom right corner
                        row = vim.o.lines - 4,
                        col = vim.o.columns - 4
                    },
                    border = {
                        style = "rounded", -- Rounded border
                        padding = { 0, 1 } -- Minimal padding
                    },
                    timeout = 3000,        -- 3 second display
                    render = "compact"     -- Compact rendering
                }
            },
            views = {
                cmdline_popup = {
                    position = {
                        row = 5,
                        col = "50%",
                    },
                    size = {
                        width = 60,
                        height = "auto",
                    },

                    border = {
                        style = "none",
                        padding = { 2, 3 },
                    },
                    filter_options = {},
                    win_options = {
                        winhighlight = {
                            NormalFloat = "NormalFloat",
                            FloatBorder = "FloatBorder"
                        },
                    },
                },
                popupmenu = {
                    backend = "notify",
                    relative = "editor",
                    position = {
                        row = "100%",
                        col = "100%",
                        offset = { row = -2, col = -20 },
                    },
                    size = {
                        width = 40,
                        height = 5,
                    },
                    border = {
                        style = "rounded",
                        padding = { 0, 1 },
                    },
                    win_options = {
                        winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                    },
                },

            },
        })
    end,
}
