return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "mfussenegger/nvim-lint",
        "rshkarin/mason-nvim-lint",
    },
    config = function()
        require("mason").setup()

        require("mason-lspconfig").setup({
            ensure_installed = {
                "jdtls",
                "lua_ls",
                "ts_ls",
            },
            automatic_installation = true,
        })

        require('mason-nvim-lint').setup({
            ensure_installed = {
                'eslint',
                'eslint_d',
                'golangci-lint',
                'checkstyle',
                'shellcheck',
            },
            automatic_installation = true
        })
    end,
}
