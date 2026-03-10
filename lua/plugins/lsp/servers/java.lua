local capabilities     = require("cmp_nvim_lsp").default_capabilities()
local jdtls            = require("jdtls")
local mason_registry   = require("mason-registry")

local jdtls_path       = mason_registry.get_package("jdtls"):get_install_path()
local lombok_jar       = jdtls_path .. "/lombok.jar"
local launcher_jar     = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir       = jdtls_path .. "/config_linux"

-- Use full path hash to avoid workspace collisions between projects with same folder name
local project_name     = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("/", "_"):gsub(":", "_")
local workspace_dir    = vim.fn.stdpath("data") .. "/jdtls/workspace/" .. project_name

-- Java project markers for root detection (includes .git for monorepos, but is_java_project() guards startup)
local java_project_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "mvnw", "gradlew", ".mvn", "settings.gradle", "settings.gradle.kts", ".git" }

-- Strict markers for is_java_project() check (no .git - we only start JDTLS for actual Java projects)
local java_strict_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "mvnw", "gradlew", ".mvn", "settings.gradle", "settings.gradle.kts" }

-- Check if current directory is a Java project (uses strict markers, no .git)
local function is_java_project()
    local root = vim.fs.find(java_strict_markers, { upward = true, path = vim.fn.expand("%:p:h") })[1]
    return root ~= nil
end

-- Common Java installation paths on Linux
local java_base_paths = {
    "/usr/lib/jvm",
    vim.fn.expand("~/.sdkman/candidates/java"),
    vim.fn.expand("~/.jdks"),
    "/opt/java",
}

-- Parse Java version from directory name
local function parse_java_version(dir_name)
    -- Match common patterns: java-17-openjdk, openjdk-17, 17.0.1-tem, temurin-17, etc.
    local version = dir_name:match("%-(%d+)%-") or dir_name:match("%-(%d+)$") or dir_name:match("^(%d+)%.")
        or dir_name:match("^(%d+)%-") or dir_name:match("java%-(%d+)") or dir_name:match("jdk%-(%d+)")
        or dir_name:match("openjdk%-(%d+)")

    if version then
        return tonumber(version)
    end

    -- Fallback: try to extract any number
    local num = dir_name:match("(%d+)")
    return num and tonumber(num) or nil
end

-- Get Java SE name from version number
local function get_java_se_name(version)
    if version == 8 or version == 1 then
        return "JavaSE-1.8"
    end
    return "JavaSE-" .. version
end

-- Find the best Java 17+ for running JDTLS itself
local function find_jdtls_java()
    local best_java = nil
    local best_version = 0

    for _, base_path in ipairs(java_base_paths) do
        if vim.fn.isdirectory(base_path) == 1 then
            local dirs = vim.fn.readdir(base_path)
            for _, dir in ipairs(dirs) do
                local java_home = base_path .. "/" .. dir
                local java_bin = java_home .. "/bin/java"
                if vim.fn.executable(java_bin) == 1 then
                    local version = parse_java_version(dir)
                    -- JDTLS requires Java 17+, prefer the newest available
                    if version and version >= 17 and version > best_version then
                        best_version = version
                        best_java = java_bin
                    end
                end
            end
        end
    end

    -- Fallback: check JAVA_HOME
    if not best_java then
        local java_home = os.getenv("JAVA_HOME")
        if java_home then
            local java_bin = java_home .. "/bin/java"
            if vim.fn.executable(java_bin) == 1 then
                best_java = java_bin
            end
        end
    end

    -- Last resort: system java (hope it's 17+)
    return best_java or "java"
end

-- Detect all installed Java runtimes for project compilation
local function detect_java_runtimes()
    local runtimes = {}
    local seen_paths = {}

    for _, base_path in ipairs(java_base_paths) do
        if vim.fn.isdirectory(base_path) == 1 then
            local dirs = vim.fn.readdir(base_path)
            for _, dir in ipairs(dirs) do
                local java_home = base_path .. "/" .. dir
                local java_bin = java_home .. "/bin/java"

                if vim.fn.executable(java_bin) == 1 and not seen_paths[java_home] then
                    seen_paths[java_home] = true
                    local version = parse_java_version(dir)

                    if version then
                        table.insert(runtimes, {
                            name = get_java_se_name(version),
                            path = java_home,
                        })
                    end
                end
            end
        end
    end

    -- Add JAVA_HOME if set and not already included
    local java_home = os.getenv("JAVA_HOME")
    if java_home and vim.fn.isdirectory(java_home) == 1 and not seen_paths[java_home] then
        local version = parse_java_version(vim.fn.fnamemodify(java_home, ":t"))
        table.insert(runtimes, {
            name = version and get_java_se_name(version) or "JavaSE-current",
            path = java_home,
            default = true,
        })
    end

    return runtimes
end

-- Get JDTLS Java binary (must be 17+)
local jdtls_java = find_jdtls_java()

-- Get debug bundles from mason (for DAP support)
local function get_debug_bundles()
    local bundles = {}
    local mason_registry = require("mason-registry")

    -- Java debug adapter
    if mason_registry.is_installed("java-debug-adapter") then
        local java_debug_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
        local debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", false, true)
        if #debug_jar > 0 then
            vim.list_extend(bundles, debug_jar)
        end
    end

    -- Java test adapter
    if mason_registry.is_installed("java-test") then
        local java_test_path = mason_registry.get_package("java-test"):get_install_path()
        local test_jars = vim.fn.glob(java_test_path .. "/extension/server/*.jar", false, true)
        vim.list_extend(bundles, test_jars)
    end

    return bundles
end

local function setup_jdtls()
    -- Only start JDTLS for actual Java projects
    if not is_java_project() then
        return
    end

    local detected_runtimes = detect_java_runtimes()
    local debug_bundles = get_debug_bundles()

    local config = {
        cmd = {
            jdtls_java, -- Use Java 17+ for JDTLS (auto-detected)
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
        -- Only look for actual Java project markers, NOT .git
        root_dir = jdtls.setup.find_root(java_project_markers),
        on_attach = function(client, bufnr)
            -- Setup DAP (Debug Adapter Protocol)
            require("jdtls").setup_dap({ hotcodereplace = "auto" })
            require("jdtls.dap").setup_dap_main_class_configs()

            -- LSP Keybindings
            local opts = { buffer = bufnr, silent = true }

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
            vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Go to References" }))
            vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

            -- Java-specific refactoring
            vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
            vim.keymap.set("n", "<leader>crv", require("jdtls").extract_variable, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("v", "<leader>crv", function() require("jdtls").extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("n", "<leader>crc", require("jdtls").extract_constant, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>crc", function() require("jdtls").extract_constant(true) end, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>crm", function() require("jdtls").extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract Method" }))

            -- Java Testing (JUnit)
            vim.keymap.set("n", "<leader>jt", require("jdtls").test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test Nearest Method" }))
            vim.keymap.set("n", "<leader>jT", require("jdtls").test_class, vim.tbl_extend("force", opts, { desc = "Test Class" }))
            vim.keymap.set("n", "<leader>jp", require("jdtls").pick_test, vim.tbl_extend("force", opts, { desc = "Pick Test" }))

            -- Java Debug
            vim.keymap.set("n", "<leader>jd", function()
                require("jdtls.dap").setup_dap_main_class_configs()
                require("dap").continue()
            end, vim.tbl_extend("force", opts, { desc = "Debug Java" }))

            -- Run main class without debugging
            vim.keymap.set("n", "<leader>jr", function()
                local main_class = vim.fn.input("Main class: ")
                if main_class ~= "" then
                    vim.cmd("terminal java " .. main_class)
                end
            end, vim.tbl_extend("force", opts, { desc = "Run Main Class" }))
        end,
        settings = {
            java = {
                eclipse = {
                    downloadSources = true,
                },
                configuration = {
                    updateBuildConfiguration = "interactive",
                    -- Register all detected Java runtimes so JDTLS knows about Java 11, 17, 21, etc.
                    runtimes = detected_runtimes,
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all",
                    },
                },
                format = {
                    enabled = true,
                },
                -- Compile with project's specified Java version
                compile = {
                    nullAnalysis = {
                        mode = "automatic",
                    },
                },
            },
        },
        init_options = {
            bundles = debug_bundles,
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
    }

    jdtls.start_or_attach(config)
end

vim.api.nvim_create_augroup("JavaLSPGroup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "JavaLSPGroup",
    pattern = "java",
    callback = function()
        setup_jdtls()
    end,
})
