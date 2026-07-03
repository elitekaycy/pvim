local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

local function get_tailwind_cmd()
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/tailwindcss-language-server"
    if vim.fn.executable(mason_bin) == 1 then
        return { mason_bin, "--stdio" }
    end
    if vim.fn.executable("tailwindcss-language-server") == 1 then
        return { "tailwindcss-language-server", "--stdio" }
    end
    return nil
end

local function has_tailwind_dependency(root_dir)
    local package_json = root_dir .. "/package.json"
    if vim.fn.filereadable(package_json) == 0 then
        return false
    end

    local lines = vim.fn.readfile(package_json)
    local content = table.concat(lines, "\n")
    return content:find('"tailwindcss"', 1, true) ~= nil
end

local function tailwind_root_dir(fname)
    local util = lspconfig.util
    local config_root = util.root_pattern(
        "tailwind.config.js",
        "tailwind.config.ts",
        "tailwind.config.cjs",
        "tailwind.config.mjs",
        "postcss.config.js"
    )(fname)
    if config_root then
        return config_root
    end

    local package_root = util.root_pattern("package.json")(fname)
    if package_root and has_tailwind_dependency(package_root) then
        return package_root
    end

    return nil
end

local tailwind_cmd = get_tailwind_cmd()
if not tailwind_cmd then
    return
end

lspconfig.tailwindcss.setup({
    capabilities = capabilities,
    cmd = tailwind_cmd,
    filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    root_dir = tailwind_root_dir,
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    "([\\w-/:]+)",
                    'class[:]\\s*"([^"]*)"',
                    'className[:]\\s*"([^"]*)"',
                },
            },
            lint = {
                cssConflict = "warning",
            },
            validate = true,
        },
    },
    on_attach = function(client, bufnr)
        codelens.on_attach(client, bufnr)

        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action (Visual)" }))
    end,
})
