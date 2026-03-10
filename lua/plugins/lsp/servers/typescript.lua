local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

lspconfig.ts_ls.setup({
    capabilities = capabilities,
    filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
    cmd = { "typescript-language-server", "--stdio" },
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", "angular.json", ".git"),
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
            },
            format = { enable = true },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
            },
            format = { enable = true },
        },
    },
    on_attach = function(client, bufnr)
        codelens.on_attach(client, bufnr)

        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to References" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action (Visual)" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))

        -- TypeScript specific
        vim.keymap.set("n", "<leader>co", function()
            vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" } } })
        end, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
        vim.keymap.set("n", "<leader>cR", function()
            vim.lsp.buf.code_action({ apply = true, context = { only = { "source.removeUnused" } } })
        end, vim.tbl_extend("force", opts, { desc = "Remove Unused" }))
    end,
})
