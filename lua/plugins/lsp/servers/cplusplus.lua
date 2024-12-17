local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

lspconfig.clangd.setup({
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--header-insertion-decorators",
        "--log=info"
    },
    on_attach = function(client, bufnr)
        print("c++ server attached")
        -- handlers.setup()
        codelens.on_attach(client, bufnr)
        -- client.server_capabilites.signatureHelpProvider = false;

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run CodeLens" })
    end,
    flags = {
        debounce_text_changes = 150,
    }
})
