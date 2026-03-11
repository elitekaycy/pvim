-- Database Client (vim-dadbod + vim-dadbod-ui)
-- Query databases directly in Neovim
return {
    {
        "tpope/vim-dadbod",
        lazy = true,
        cmd = { "DB" },
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        dependencies = {
            "tpope/vim-dadbod",
            { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
        },
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        keys = {
            { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
            { "<leader>da", "<cmd>DBUIAddConnection<cr>", desc = "Add DB connection" },
            { "<leader>df", "<cmd>DBUIFindBuffer<cr>", desc = "Find DB buffer" },
        },
        init = function()
            -- Configuration
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_database_icon = 1
            vim.g.db_ui_force_echo_notifications = 1

            -- Save location for queries
            vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

            -- Auto-execute on save
            vim.g.db_ui_execute_on_save = 0

            -- Table helpers - useful shortcuts
            vim.g.db_ui_table_helpers = {
                mysql = {
                    Count = "SELECT COUNT(*) FROM {table}",
                    Describe = "DESCRIBE {table}",
                    ["Show Create"] = "SHOW CREATE TABLE {table}",
                },
                postgresql = {
                    Count = "SELECT COUNT(*) FROM {table}",
                    Describe = "\\d+ {table}",
                    ["List Indexes"] = "SELECT * FROM pg_indexes WHERE tablename = '{table}'",
                },
                sqlite = {
                    Count = "SELECT COUNT(*) FROM {table}",
                    Schema = ".schema {table}",
                },
            }

            -- Icons
            vim.g.db_ui_icons = {
                expanded = "▾",
                collapsed = "▸",
                saved_query = "󰆓",
                new_query = "󰓰",
                tables = "󰓫",
                buffers = "󰈔",
                connection_ok = "✓",
                connection_error = "✗",
            }
        end,
        config = function()
            -- Setup completion for SQL files
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    -- Add dadbod completion source to nvim-cmp
                    local ok, cmp = pcall(require, "cmp")
                    if ok then
                        cmp.setup.buffer({
                            sources = cmp.config.sources({
                                { name = "vim-dadbod-completion" },
                                { name = "buffer" },
                            }),
                        })
                    end
                end,
            })

            -- Keymaps for SQL buffers
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "sql", "mysql", "plsql" },
                callback = function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    vim.keymap.set("n", "<leader>de", "<Plug>(DBUI_ExecuteQuery)", { buffer = bufnr, desc = "Execute query" })
                    vim.keymap.set("v", "<leader>de", "<Plug>(DBUI_ExecuteQuery)", { buffer = bufnr, desc = "Execute selection" })
                    vim.keymap.set("n", "<leader>ds", "<Plug>(DBUI_SaveQuery)", { buffer = bufnr, desc = "Save query" })
                end,
            })
        end,
    },
}
