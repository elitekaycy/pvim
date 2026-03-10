return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "mfussenegger/nvim-lint",
        "rshkarin/mason-nvim-lint",
        "jay-babu/mason-nvim-dap.nvim",
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
    },
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                -- Web
                "html",
                "ts_ls",
                "tailwindcss",
                "cssls",
                -- Angular
                "angularls",
                -- Lua
                "lua_ls",
                -- C/C++
                "clangd",
                -- Java (installed by mason, but configured by nvim-jdtls directly)
                "jdtls",
            },
            automatic_installation = true,
            -- Exclude jdtls from automatic enable - we use nvim-jdtls plugin directly
            automatic_enable = {
                exclude = { "jdtls" },
            },
        })

        -- mason-nvim-lint can fail if linters aren't available
        pcall(function()
            require("mason-nvim-lint").setup({
                ensure_installed = {
                    "eslint_d",
                    "shellcheck",
                },
                automatic_installation = true,
            })
        end)

        -- mason-nvim-dap can fail if adapters aren't available
        pcall(function()
            require("mason-nvim-dap").setup({
                ensure_installed = {
                    "java-debug-adapter",
                    "java-test",
                    "codelldb",
                },
                automatic_installation = true,
            })
        end)
    end,
}
