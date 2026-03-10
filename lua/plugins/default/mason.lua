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
                -- Java
                "jdtls",
                -- Lua
                "lua_ls",
                -- C/C++
                "clangd",
            },
            automatic_installation = true,
        })

        require("mason-nvim-lint").setup({
            ensure_installed = {
                "eslint_d",
                "golangci-lint",
                "checkstyle",
                "shellcheck",
            },
            automatic_installation = true,
        })

        require("mason-nvim-dap").setup({
            ensure_installed = {
                -- Java debugging
                "java-debug-adapter",
                "java-test",
                -- C/C++ debugging
                "codelldb",
            },
            automatic_installation = true,
        })
    end,
}
