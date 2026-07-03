local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

local kotlin_project_markers = {
    "settings.gradle.kts",
    "settings.gradle",
    "build.gradle.kts",
    "build.gradle",
    "pom.xml",
    "gradlew",
    "mvnw",
    ".mvn",
}

local function is_kotlin_project()
    local root = vim.fs.find(kotlin_project_markers, { upward = true, path = vim.fn.expand("%:p:h") })[1]
    return root ~= nil
end

local function find_root()
    local found = vim.fs.find(kotlin_project_markers, { upward = true, path = vim.fn.expand("%:p:h") })[1]
    if found then
        return vim.fn.fnamemodify(found, ":h")
    end
    return vim.fn.getcwd()
end

local function get_kotlin_lsp_cmd()
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/kotlin-language-server"
    if vim.fn.executable(mason_bin) == 1 then
        return { mason_bin }
    end
    if vim.fn.executable("kotlin-language-server") == 1 then
        return { "kotlin-language-server" }
    end
    return nil
end

local function get_kotlin_debug_adapter()
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/kotlin-debug-adapter"
    if vim.fn.executable(mason_bin) == 1 then
        return mason_bin
    end
    if vim.fn.executable("kotlin-debug-adapter") == 1 then
        return "kotlin-debug-adapter"
    end
    return nil
end

local function on_attach(client, bufnr)
    codelens.on_attach(client, bufnr)

    local opts = { buffer = bufnr, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to References" }))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
    vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action (Visual)" }))
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))

    -- Kotlin DAP: run/debug current main class
    local debug_adapter = get_kotlin_debug_adapter()
    if debug_adapter then
        local ok, dap = pcall(require, "dap")
        if ok then
            dap.adapters.kotlin = {
                type = "executable",
                command = debug_adapter,
            }
            dap.configurations.kotlin = {
                {
                    type = "kotlin",
                    request = "launch",
                    name = "Launch Kotlin Main",
                    projectRoot = "${workspaceFolder}",
                    mainClass = function()
                        return vim.fn.input("Main class (e.g. com.foo.MainKt): ")
                    end,
                },
                {
                    type = "kotlin",
                    request = "attach",
                    name = "Attach Remote (port 5005)",
                    projectRoot = "${workspaceFolder}",
                    hostName = "localhost",
                    port = 5005,
                    timeout = 2000,
                },
            }

            vim.keymap.set("n", "<leader>kd", function()
                require("dap").continue()
            end, vim.tbl_extend("force", opts, { desc = "Debug Kotlin" }))
        end
    end
end

local function setup_kotlin_lsp()
    if not is_kotlin_project() then
        return
    end

    local cmd = get_kotlin_lsp_cmd()
    if not cmd then
        vim.notify("kotlin-language-server not installed. Run :MasonInstall kotlin-language-server", vim.log.levels.WARN)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local root_dir = find_root()

    -- Reuse an existing client if one already serves this root
    for _, client in ipairs(vim.lsp.get_clients({ name = "kotlin_language_server" })) do
        if client.config.root_dir == root_dir then
            vim.lsp.buf_attach_client(bufnr, client.id)
            return
        end
    end

    local client_id = vim.lsp.start({
        name = "kotlin_language_server",
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            kotlin = {
                compiler = {
                    jvm = {
                        target = "17",
                    },
                },
                completion = {
                    snippets = {
                        enabled = true,
                    },
                },
                indexing = {
                    enabled = true,
                },
                inlayHints = {
                    typeHints = true,
                    parameterHints = true,
                    chainedHints = true,
                },
            },
        },
    })

    if client_id then
        vim.lsp.buf_attach_client(bufnr, client_id)
    end
end

vim.api.nvim_create_augroup("KotlinLSPGroup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "KotlinLSPGroup",
    pattern = "kotlin",
    callback = function()
        vim.schedule(setup_kotlin_lsp)
    end,
})
