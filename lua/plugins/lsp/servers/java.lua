local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Get jdtls paths - check mason install path directly for reliability
local function get_jdtls_paths()
    -- Try mason path first (most reliable)
    local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
    if vim.fn.isdirectory(mason_path) == 1 then
        local launcher_jar = vim.fn.glob(mason_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        if launcher_jar ~= "" then
            return {
                path = mason_path,
                lombok_jar = mason_path .. "/lombok.jar",
                launcher_jar = launcher_jar,
                config_dir = mason_path .. "/config_linux",
            }
        end
    end

    -- Fallback: try mason-registry API
    local ok, mason_registry = pcall(require, "mason-registry")
    if ok then
        local pkg_ok, jdtls_pkg = pcall(mason_registry.get_package, "jdtls")
        if pkg_ok and jdtls_pkg and jdtls_pkg.is_installed and jdtls_pkg:is_installed() then
            local path_ok, jdtls_path = pcall(function() return jdtls_pkg:get_install_path() end)
            if path_ok and jdtls_path then
                return {
                    path = jdtls_path,
                    lombok_jar = jdtls_path .. "/lombok.jar",
                    launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
                    config_dir = jdtls_path .. "/config_linux",
                }
            end
        end
    end

    return nil
end

-- Use full path hash to avoid workspace collisions between projects with same folder name
local function get_workspace_dir()
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p"):gsub("/", "_"):gsub(":", "_")
    return vim.fn.stdpath("data") .. "/jdtls/workspace/" .. project_name
end

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
    vim.fn.expand("~/.asdf/installs/java"),  -- asdf version manager
    vim.fn.expand("~/.local/share/mise/installs/java"),  -- mise version manager
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

-- Get debug bundles from mason (for DAP support) - uses direct path for reliability
local function get_debug_bundles()
    local bundles = {}
    local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"

    -- Java debug adapter
    local java_debug_path = mason_packages .. "/java-debug-adapter"
    if vim.fn.isdirectory(java_debug_path) == 1 then
        local debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", false, true)
        if #debug_jar > 0 then
            vim.list_extend(bundles, debug_jar)
        end
    end

    -- Java test adapter
    local java_test_path = mason_packages .. "/java-test"
    if vim.fn.isdirectory(java_test_path) == 1 then
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

    -- Get JDTLS paths (deferred to ensure mason has installed packages)
    local paths = get_jdtls_paths()
    if not paths then
        vim.notify("JDTLS not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
        return
    end

    local jdtls = require("jdtls")
    local jdtls_java = find_jdtls_java()
    local workspace_dir = get_workspace_dir()
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
            "-javaagent:" .. paths.lombok_jar,
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens=java.base/java.util=ALL-UNNAMED",
            "--add-opens=java.base/java.lang=ALL-UNNAMED",
            "-jar",
            paths.launcher_jar,
            "-configuration",
            paths.config_dir,
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
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename Symbol" }))

            -- Code Actions (normal and visual mode)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action" }))
            vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code Action (Visual)" }))

            -- Java-specific refactoring (under <leader>cr prefix)
            vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
            vim.keymap.set("n", "<leader>crv", require("jdtls").extract_variable, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("v", "<leader>crv", function() require("jdtls").extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
            vim.keymap.set("n", "<leader>crc", require("jdtls").extract_constant, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>crc", function() require("jdtls").extract_constant(true) end, vim.tbl_extend("force", opts, { desc = "Extract Constant" }))
            vim.keymap.set("v", "<leader>crm", function() require("jdtls").extract_method(true) end, vim.tbl_extend("force", opts, { desc = "Extract Method" }))

            -- Additional Java code actions
            vim.keymap.set("n", "<leader>cri", function()
                require("jdtls").extract_variable()
                vim.schedule(function() require("jdtls").organize_imports() end)
            end, vim.tbl_extend("force", opts, { desc = "Extract & Import" }))

            -- Super type hierarchy
            vim.keymap.set("n", "<leader>cs", require("jdtls").super_implementation, vim.tbl_extend("force", opts, { desc = "Go to Super Implementation" }))

            -- Java source actions menu
            vim.keymap.set("n", "<leader>cg", function()
                local actions = {
                    { name = "Generate Constructors", action = function() require("jdtls").generate_constructors() end },
                    { name = "Generate toString()", action = function() require("jdtls").generate_toString() end },
                    { name = "Generate hashCode/equals", action = function() require("jdtls").generate_hashCode_and_equals() end },
                    { name = "Generate Getters", action = function() require("jdtls").generate_accessors({ kind = "getter" }) end },
                    { name = "Generate Setters", action = function() require("jdtls").generate_accessors({ kind = "setter" }) end },
                    { name = "Generate Getters & Setters", action = function() require("jdtls").generate_accessors() end },
                    { name = "Generate Delegate Methods", action = function() require("jdtls").generate_delegate_methods() end },
                    { name = "Override Methods", action = function() require("jdtls").override_methods() end },
                }
                vim.ui.select(actions, {
                    prompt = "Java Generate:",
                    format_item = function(item) return item.name end,
                }, function(choice)
                    if choice then choice.action() end
                end)
            end, vim.tbl_extend("force", opts, { desc = "Generate Code Menu" }))

            -- Quick generate shortcuts
            vim.keymap.set("n", "<leader>cgc", function() require("jdtls").generate_constructors() end, vim.tbl_extend("force", opts, { desc = "Generate Constructor" }))
            vim.keymap.set("n", "<leader>cgt", function() require("jdtls").generate_toString() end, vim.tbl_extend("force", opts, { desc = "Generate toString()" }))
            vim.keymap.set("n", "<leader>cge", function() require("jdtls").generate_hashCode_and_equals() end, vim.tbl_extend("force", opts, { desc = "Generate equals/hashCode" }))
            vim.keymap.set("n", "<leader>cgg", function() require("jdtls").generate_accessors({ kind = "getter" }) end, vim.tbl_extend("force", opts, { desc = "Generate Getters" }))
            vim.keymap.set("n", "<leader>cgs", function() require("jdtls").generate_accessors({ kind = "setter" }) end, vim.tbl_extend("force", opts, { desc = "Generate Setters" }))
            vim.keymap.set("n", "<leader>cga", function() require("jdtls").generate_accessors() end, vim.tbl_extend("force", opts, { desc = "Generate All Accessors" }))
            vim.keymap.set("n", "<leader>cgd", function() require("jdtls").generate_delegate_methods() end, vim.tbl_extend("force", opts, { desc = "Generate Delegate Methods" }))
            vim.keymap.set("n", "<leader>cgo", function() require("jdtls").override_methods() end, vim.tbl_extend("force", opts, { desc = "Override Methods" }))

            -- Java build and compile
            vim.keymap.set("n", "<leader>jb", function() require("jdtls").build_projects() end, vim.tbl_extend("force", opts, { desc = "Build Projects" }))
            vim.keymap.set("n", "<leader>ju", function() require("jdtls").update_project_config() end, vim.tbl_extend("force", opts, { desc = "Update Project Config" }))
            vim.keymap.set("n", "<leader>jc", function() require("jdtls").compile("full") end, vim.tbl_extend("force", opts, { desc = "Compile (Full)" }))
            vim.keymap.set("n", "<leader>ji", function() require("jdtls").compile("incremental") end, vim.tbl_extend("force", opts, { desc = "Compile (Incremental)" }))

            -- Java Testing (JUnit)
            vim.keymap.set("n", "<leader>jt", require("jdtls").test_nearest_method, vim.tbl_extend("force", opts, { desc = "Test Nearest Method" }))
            vim.keymap.set("n", "<leader>jT", require("jdtls").test_class, vim.tbl_extend("force", opts, { desc = "Test Class" }))
            vim.keymap.set("n", "<leader>jp", require("jdtls").pick_test, vim.tbl_extend("force", opts, { desc = "Pick Test" }))

            -- Java Debug
            vim.keymap.set("n", "<leader>jd", function()
                require("jdtls.dap").setup_dap_main_class_configs()
                require("dap").continue()
            end, vim.tbl_extend("force", opts, { desc = "Debug Java" }))

            -- Run main class
            vim.keymap.set("n", "<leader>jr", function()
                require("jdtls.dap").setup_dap_main_class_configs()
                -- Try to run without debugging
                local dap = require("dap")
                dap.run({
                    type = "java",
                    request = "launch",
                    name = "Run Main",
                    mainClass = function()
                        return vim.fn.input("Main class: ")
                    end,
                    console = "integratedTerminal",
                    noDebug = true,
                })
            end, vim.tbl_extend("force", opts, { desc = "Run Main Class" }))

            -- Java workspace management
            vim.keymap.set("n", "<leader>jw", function()
                local actions = {
                    { name = "Clean Workspace", action = function() vim.cmd("JdtWipeDataAndRestart") end },
                    { name = "Update Project Config", action = function() require("jdtls").update_project_config() end },
                    { name = "Build Projects", action = function() require("jdtls").build_projects() end },
                    { name = "Refresh File", action = function() vim.cmd("edit!") end },
                }
                vim.ui.select(actions, {
                    prompt = "Java Workspace:",
                    format_item = function(item) return item.name end,
                }, function(choice)
                    if choice then choice.action() end
                end)
            end, vim.tbl_extend("force", opts, { desc = "Workspace Menu" }))
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
