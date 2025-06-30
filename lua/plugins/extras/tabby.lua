return {
    {
        "TabbyML/vim-tabby",
        lazy = false,
        dependencies = { "neovim/nvim-lspconfig" },
        init = function()
            -- Minimal required settings
            vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
            vim.g.tabby_inline_completion_trigger = "auto"
        end,
        config = function()
            -- Essential LSP setup
            require("lspconfig").tabby.setup({
                filetypes = {
                    "python", "javascript", "typescript", "lua",
                    "go", "rust", "java", "c", "cpp"
                }
            })

            -- Core keymaps only
            vim.keymap.set("i", "<Tab>", function()
                return vim.fn["tabby#Accept"]() == 1 and "" or "<Tab>"
            end, { expr = true, silent = true })

            vim.keymap.set("i", "<C-\\>", function()
                vim.fn["tabby#TriggerOrDismiss"]()
                return ""
            end, { expr = true, silent = true })
        end
    }
}
