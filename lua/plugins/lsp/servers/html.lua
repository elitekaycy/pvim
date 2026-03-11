local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

-- Register Java template filetypes
vim.filetype.add({
    extension = {
        ftl = "ftl",      -- FreeMarker Template Language
        jsp = "jsp",      -- JavaServer Pages
        jspx = "jspx",    -- JSP XML syntax
        jspf = "jsp",     -- JSP Fragment
        tag = "jsp",      -- JSP Tag files
    },
})

-- Set ftl to be treated like html for syntax highlighting
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.ftl",
    callback = function()
        vim.bo.filetype = "ftl"
        vim.cmd("setlocal syntax=html")
    end,
})

-- Set jsp/jspx to be treated like html for syntax highlighting
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.jsp", "*.jspx", "*.jspf", "*.tag" },
    callback = function()
        vim.cmd("setlocal syntax=jsp")
        -- Fallback to HTML syntax if JSP syntax not available
        if vim.fn.exists("b:current_syntax") == 0 then
            vim.cmd("setlocal syntax=html")
        end
    end,
})

lspconfig.html.setup({
    capabilities = capabilities,
    filetypes = { "html", "jsp", "jspx", "ftl", "templ", "htmldjango" },
    settings = {
        html = {
            format = {
                enable = true,
                wrapLineLength = 120,
            },
            hover = {
                documentation = true,
                references = true,
            },
        },
    },
    on_attach = function(client, bufnr)
        codelens.on_attach(client, bufnr)

        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action (Visual)" }))
        vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))
    end,
})
