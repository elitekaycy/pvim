return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            disable_netrw = true,
            hijack_netrw = true,
            auto_reload_on_write = true,
            reload_on_bufenter = true,
            hijack_unnamed_buffer_when_opening = false,
            update_focused_file = {
                enable = false,
            },

            view = {
                side = "left",
                preserve_window_proportions = false,
                width = {
                    min = 30,
                    max = 60,
                    padding = 1
                },
                centralize_selection = false,
                cursorline = true,
                number = false,
                relativenumber = false,
                signcolumn = "yes",
                float = {
                    enable = true,
                    quit_on_focus_loss = true,
                    open_win_config = function()
                        local screen_h = vim.opt.lines:get()
                        return {
                            relative = "editor",
                            border = "rounded",
                            width = 30,
                            height = screen_h - 4,
                            row = 1,
                            col = 1,
                        }
                    end,

                },
            },

            renderer = {
                highlight_git = true,
                add_trailing = false,
                highlight_opened_files = "all",
                indent_markers = {
                    enable = true,
                    inline_arrows = true,
                    icons = {
                        corner = "└",
                        edge = "│",
                        item = "│",
                        bottom = "─",
                        none = " ",
                    },
                },
                icons = {
                    web_devicons = {
                        file = {
                            enable = true,
                            color = true,
                        },
                        folder = {
                            enable = false,
                            color = true,
                        },
                    },
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                        modified = true,
                        hidden = true,
                        diagnostics = false,
                        bookmarks = true,
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        bookmark = "󰆤",
                        modified = "●",
                        hidden = "󰜌",
                        folder = {
                            arrow_closed = ">",
                            arrow_open = "",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "✗",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
            },

            hijack_directories = {
                enable = true,
                auto_open = true,
            },

            actions = {
                open_file = {
                    quit_on_open = false,
                    resize_window = true,
                    window_picker = {
                        enable = true,
                        picker = "default",
                        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                        exclude = {
                            filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
                            buftype = { "nofile", "terminal", "help" },
                        },
                    },
                },
            },

            trash = {
                cmd = "gio trash",
            },

            git = {
                enable = true,
                show_on_dirs = true,
                show_on_open_dirs = true,
            },

            diagnostics = {
                enable = true,
                show_on_dirs = true,
                debounce_delay = 500,
            },

            filters = {
                enable = true,
                git_ignored = true,
                dotfiles = false,
            },


        })

        local function set_highlight(group, properties)
            vim.api.nvim_set_hl(0, group, properties)
        end

        set_highlight("NvimTreeNormal", { bg = "#1e1e2e" })
        set_highlight("NvimTreeNormalNC", { bg = "#1e1e2e" })

        set_highlight("NvimTreeWindowPicker", { fg = "#ffffff", bg = "#5e81ac", bold = true })

        set_highlight("NvimTreeGitDirty", { fg = "#d08770", bold = true })
        set_highlight("NvimTreeGitNew", { fg = "#a3be8c", bold = true })
        set_highlight("NvimTreeGitDeleted", { fg = "#bf616a", bold = true })

        set_highlight("NvimTreeFolderIcon", { fg = "#81a1c1" })
        set_highlight("NvimTreeFileIcon", { fg = "#88c0d0" })
        set_highlight("NvimTreeRootFolder", { fg = "#88c0d0", bold = true })

        set_highlight("NvimTreeDiagnosticError", { fg = "#bf616a" })
        set_highlight("NvimTreeDiagnosticWarn", { fg = "#ebcb8b" })
        set_highlight("NvimTreeDiagnosticInfo", { fg = "#88c0d0" })
        set_highlight("NvimTreeDiagnosticHint", { fg = "#5e81ac" })
    end,
}
