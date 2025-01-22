local capabilities   = require("cmp_nvim_lsp").default_capabilities()
local jdtls          = require("jdtls")
-- local handlers = require("plugins.lsp.handlers")
local mason_registry = require("mason-registry")
-- local codelens       = require("utils.codelens")

local jdtls_path     = mason_registry.get_package("jdtls"):get_install_path()
local lombok_jar     = jdtls_path .. "/lombok.jar"
local launcher_jar   = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir     = jdtls_path .. "/config_linux"
local workspace_dir  = vim.fn.stdpath("data") ..
    "/jdtls/workspace/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local function setup_jdtls()
    local config = {
        cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-javaagent:" .. lombok_jar,
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens=java.base/java.util=ALL-UNNAMED",
            "--add-opens=java.base/java.lang=ALL-UNNAMED",
            "-jar",
            launcher_jar,
            "-configuration",
            config_dir,
            "-data",
            workspace_dir,
        },
        capabilities = capabilities,
        root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        on_attach = function()
            require("jdtls").setup_dap { hotcodereplace = "auto" }
            require("jdtls.dap").setup_dap_main_class_configs()
            require("jtdtls").add_commands()
        end,
        settings = {
            java = {
                eclipse = {
                    downloadSources = true,
                },
                configuration = {
                    updateBuildConfiguration = "interactive",
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all",
                    },
                },
                format = {
                    enabled = false,
                },
            },
        },
        init_options = {
            bundles = {
                -- java_debug_adapter_path
            },
        },
    }

    jdtls.start_or_attach(config)

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = 0 })

    vim.keymap.set(
        "n",
        "<leader>co",
        "<Cmd>lua require'jdtls'.organize_imports()<CR>",
        { buffer = 0, desc = "Organize Imports" }
    )

    vim.keymap.set(
        "n",
        "<leader>crv",
        "<Cmd>lua require('jdtls').extract_variable()<CR>",
        { buffer = 0, desc = "Extract Variable" }
    )
    vim.keymap.set(
        "v",
        "<leader>crv",
        "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
        { buffer = 0, desc = "Extract Variable" }
    )

    vim.keymap.set(
        "n",
        "<leader>crc",
        "<Cmd>lua require('jdtls').extract_constant()<CR>",
        { buffer = 0, desc = "Extract Constant" }
    )
    vim.keymap.set(
        "v",
        "<leader>crc",
        "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
        { buffer = 0, desc = "Extract Constant" }
    )
    vim.keymap.set('n', '<leader>jt', jdtls.test_nearest_method, config)
    vim.keymap.set('n', '<leader>jT', jdtls.test_class, config)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "java" },
    callback = setup_jdtls,
})
