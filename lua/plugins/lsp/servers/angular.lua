local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

-- Angular Language Server for Angular projects
-- Only starts if angular.json exists AND node_modules/typescript is present
local function angular_root_dir(fname)
    local util = lspconfig.util
    local angular_root = util.root_pattern("angular.json", "project.json")(fname)
    if not angular_root then
        return nil
    end
    -- Check if TypeScript is installed in the project
    local ts_path = angular_root .. "/node_modules/typescript"
    if vim.fn.isdirectory(ts_path) == 0 then
        return nil  -- Don't start if TypeScript isn't installed
    end
    return angular_root
end

lspconfig.angularls.setup({
    capabilities = capabilities,
    filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx" },
    root_dir = angular_root_dir,
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
    end,
})
