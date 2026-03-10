local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

-- Clangd has offsetEncoding issues with some plugins
local clangd_capabilities = vim.deepcopy(capabilities)
clangd_capabilities.offsetEncoding = { "utf-16" }

lspconfig.clangd.setup({
    capabilities = clangd_capabilities,
    cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--header-insertion-decorators",
        "--log=info",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".clangd", ".git"),
    on_attach = function(client, bufnr)
        codelens.on_attach(client, bufnr)

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run CodeLens" })
        vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Go to References" })
        vim.keymap.set("n", "<leader>sh", "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = bufnr, desc = "Switch Header/Source" })
    end,
    flags = {
        debounce_text_changes = 150,
    },
})
