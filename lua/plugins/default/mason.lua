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
            ensure_installed = {
                "clangd-format",
                "codelldb"
            }
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "html",
                "jdtls",
                "lua_ls",
                "ts_ls",
                "clangd",
            },
            automatic_installation = true,
        })

        require('mason-nvim-lint').setup({
            ensure_installed = {
                'eslint_d',
                'golangci-lint',
                'checkstyle',
                'shellcheck',
            },
            automatic_installation = true
        })

        require("mason-nvim-dap").setup({
            ensure_installed = {
                "java-debug-adapter",
                "java-test"
            },
            automatic_installation = true,
        })
    end,
}
