local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local handlers = require("plugins.lsp.handlers")
local codelens = require("utils.codelens")

lspconfig.html.setup({
    capabilities = capabilities,
    filetypes = { 'html', 'jsp', 'ftl', 'jsp' },
    settings = {},
    on_attach = function(client, bufnr)
        print("(html/jsp/ftl..) server attached")
        codelens.on_attach(client, bufnr)

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run CodeLens" })
    end,
})
