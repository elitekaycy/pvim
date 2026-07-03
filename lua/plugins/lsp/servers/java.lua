local M = {}
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local codelens = require("utils.codelens")

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

-- Use detected project root, not cwd, for workspace identity so the same project
-- reuses a single JDTLS cache even when Neovim is launched from different folders.
local function get_hashed_workspace_dir(root_dir)
    local normalized_root = vim.fs.normalize(root_dir)
    local project_name = vim.fs.basename(normalized_root)
    local project_hash = vim.fn.sha256(normalized_root):sub(1, 12)
    return string.format("%s/jdtls/workspace/%s-%s", vim.fn.stdpath("data"), project_name, project_hash)
end

local function get_legacy_workspace_dir(root_dir)
    local legacy_name = vim.fs.normalize(root_dir):gsub("/", "_"):gsub(":", "_")
    return vim.fn.stdpath("data") .. "/jdtls/workspace/" .. legacy_name
end

local function has_jdtls_metadata(dir)
    return vim.fn.filereadable(dir .. "/.metadata/.log") == 1
end

local function get_workspace_dir(root_dir)
    local hashed_dir = get_hashed_workspace_dir(root_dir)
    local legacy_dir = get_legacy_workspace_dir(root_dir)

    if has_jdtls_metadata(hashed_dir) then
        return hashed_dir
    end

    if has_jdtls_metadata(legacy_dir) then
        return legacy_dir
    end

    return hashed_dir
end

local function get_workspace_log_path(workspace_dir)
    return workspace_dir .. "/.metadata/.log"
end

local function has_broken_workspace_index(workspace_dir)
    local log_path = get_workspace_log_path(workspace_dir)
    if vim.fn.filereadable(log_path) == 0 then
        return false
    end

    local ok, lines = pcall(vim.fn.readfile, log_path)
    if not ok or not lines or #lines == 0 then
        return false
    end

    local start = math.max(1, #lines - 400)
    for i = start, #lines do
        local line = lines[i]
        if line:find("Java Index broken", 1, true)
            or line:find("Failed to save JDT index", 1, true)
            or line:find("OutOfMemoryError: Java heap space", 1, true) then
            return true
        end
    end

    return false
end

local function repair_workspace_index_if_needed(workspace_dir)
    local marker = workspace_dir .. "/.metadata/.pvim-jdt-index-repaired"
    if vim.fn.filereadable(marker) == 1 then
        return
    end

    if not has_broken_workspace_index(workspace_dir) then
        return
    end

    local index_dir = workspace_dir .. "/.metadata/.plugins/org.eclipse.jdt.core"
    if vim.fn.isdirectory(index_dir) == 0 then
        return
    end

    local cache_files = {
        "*.index",
        "assumedExternalFilesCache",
        "externalFilesCache",
        "externalLibsTimeStamps",
        "indexNamesMap.txt",
        "javaLikeNames.txt",
        "nonChainingJarsCache",
        "savedIndexNames.txt",
        "variablesAndContainers.dat",
    }

    for _, pattern in ipairs(cache_files) do
        local matches = vim.fn.glob(index_dir .. "/" .. pattern, false, true)
        for _, path in ipairs(matches) do
            pcall(vim.fn.delete, path)
        end
    end

    pcall(vim.fn.writefile, { os.date("!%Y-%m-%dT%H:%M:%SZ") }, marker)
    vim.schedule(function()
        vim.notify("Repaired broken JDTLS workspace index cache for faster future reloads", vim.log.levels.INFO)
    end)
end

local function get_shared_index_dir()
    local index_dir = vim.fs.normalize(vim.fn.expand("~/.cache/.jdt/index"))
    vim.fn.mkdir(index_dir, "p")
    return index_dir
end

-- Strict markers for is_java_project() check (no .git - we only start JDTLS for actual Java projects)
local java_strict_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "mvnw", "gradlew", ".mvn", "settings.gradle", "settings.gradle.kts" }

local function find_java_root(startpath)
    local path = startpath or vim.api.nvim_buf_get_name(0)
    if path == "" then
        path = vim.fn.getcwd()
    end

    local search_from = vim.fs.dirname(path) or path
    local strict_root = vim.fs.find(java_strict_markers, { upward = true, path = search_from })[1]
    if strict_root then
        return vim.fs.dirname(strict_root)
    end

    local git_root = vim.fs.find({ ".git" }, { upward = true, path = search_from })[1]
    if git_root then
        local root_dir = vim.fs.dirname(git_root)
        if vim.fn.isdirectory(root_dir .. "/src/main/java") == 1
            or vim.fn.isdirectory(root_dir .. "/src/test/java") == 1
            or vim.fn.isdirectory(root_dir .. "/src") == 1 then
            return root_dir
        end
    end

    return nil
end

-- Common Java installation paths on Linux
local java_base_paths = {
    "/usr/lib/jvm",
    vim.fn.expand("~/.sdkman/candidates/java"),
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

-- Find the best Java for running JDTLS itself.
-- JDTLS requires Java 17+ but is NOT compatible with Java 25+ (current JDTLS ships against 17/21 LTS).
-- Picking Java 25 causes "client jdtls quit with exit code 13" on startup.
local JDTLS_MIN_JAVA = 17
local JDTLS_MAX_JAVA = 21
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
                    -- Prefer newest LTS in [17, 21] range (JDTLS-compatible)
                    if version and version >= JDTLS_MIN_JAVA and version <= JDTLS_MAX_JAVA and version > best_version then
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
    local runtimes_by_name = {}
    local seen_paths = {}
    local preferred_versions = {
        [8] = true,
        [11] = true,
        [17] = true,
        [21] = true,
        [23] = true,
    }

    local function maybe_add_runtime(java_home, version, is_default)
        if not version or not preferred_versions[version] then
            return
        end

        local name = get_java_se_name(version)
        local existing = runtimes_by_name[name]
        local runtime = {
            name = name,
            path = java_home,
        }

        if is_default then
            runtime.default = true
        end

        if not existing or (is_default and not existing.default) then
            runtimes_by_name[name] = runtime
        end
    end

    for _, base_path in ipairs(java_base_paths) do
        if vim.fn.isdirectory(base_path) == 1 then
            local dirs = vim.fn.readdir(base_path)
            for _, dir in ipairs(dirs) do
                local java_home = base_path .. "/" .. dir
                local java_bin = java_home .. "/bin/java"

                if vim.fn.executable(java_bin) == 1 and not seen_paths[java_home] then
                    seen_paths[java_home] = true
                    local version = parse_java_version(dir)
                    maybe_add_runtime(java_home, version, false)
                end
            end
        end
    end

    -- Add JAVA_HOME if set and not already included
    local java_home = os.getenv("JAVA_HOME")
    if java_home and vim.fn.isdirectory(java_home) == 1 and not seen_paths[java_home] then
        local version = parse_java_version(vim.fn.fnamemodify(java_home, ":t"))
        maybe_add_runtime(java_home, version, true)
    end

    local runtimes = {}
    for _, version in ipairs({ 8, 11, 17, 21, 23 }) do
        local name = get_java_se_name(version)
        if runtimes_by_name[name] then
            table.insert(runtimes, runtimes_by_name[name])
        end
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

-- Module-level caches: computed once, reused across every Java file open
local cached_paths = nil
local cached_jdtls_java = nil
local cached_runtimes = nil
local cached_debug_bundles = nil
local missing_jdtls_notified = false
local dap_initialized_roots = {}
local debug_enabled_roots = {}

local function ensure_caches()
    if cached_paths == nil then
        cached_paths = get_jdtls_paths() or false
    end
    if cached_jdtls_java == nil then
        cached_jdtls_java = find_jdtls_java()
    end
    if cached_runtimes == nil then
        cached_runtimes = detect_java_runtimes()
    end
    if cached_debug_bundles == nil then
        cached_debug_bundles = get_debug_bundles()
    end
end

local function ensure_debug_bundles()
    if cached_debug_bundles == nil then
        cached_debug_bundles = get_debug_bundles()
    end
    return cached_debug_bundles
end

local function ensure_jdtls_dap(root_dir)
    if dap_initialized_roots[root_dir] then
        return
    end

    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
        pcall(function()
            require("lazy").load({ plugins = { "nvim-jdtls" } })
        end)
        ok, jdtls = pcall(require, "jdtls")
    end
    if not ok then
        return
    end

    jdtls.setup_dap({ hotcodereplace = "auto" })
    dap_initialized_roots[root_dir] = true
end

local function client_has_debug_bundles(root_dir)
    for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
        if client.config and client.config.root_dir == root_dir then
            local bundles = client.config.init_options and client.config.init_options.bundles or {}
            return type(bundles) == "table" and #bundles > 0
        end
    end

    return false
end

local function restart_jdtls_with_debug(root_dir, startpath)
    debug_enabled_roots[root_dir] = true
    dap_initialized_roots[root_dir] = nil

    for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
        if client.config and client.config.root_dir == root_dir then
            client:stop(true)
        end
    end

    vim.defer_fn(function()
        setup_jdtls(startpath)
    end, 150)
end

local function ensure_debug_ready(root_dir, startpath, feature_name)
    if client_has_debug_bundles(root_dir) then
        return true
    end

    restart_jdtls_with_debug(root_dir, startpath)
    vim.notify(
        string.format("Restarting JDTLS with debug/test bundles for %s. Run %s again in a moment.", root_dir, feature_name),
        vim.log.levels.INFO
    )
    return false
end

local function get_jdtls_module()
    local ok, jdtls = pcall(require, "jdtls")
    if ok then
        return jdtls
    end

    pcall(function()
        require("lazy").load({ plugins = { "nvim-jdtls" } })
    end)

    ok, jdtls = pcall(require, "jdtls")
    if ok then
        return jdtls
    end

    return nil
end

local function setup_jdtls(startpath)
    local root_dir = find_java_root(startpath)
    if not root_dir then
        return
    end

    ensure_caches()

    if not cached_paths then
        if not missing_jdtls_notified then
            missing_jdtls_notified = true
            vim.notify("JDTLS not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
        end
        return
    end

    local paths = cached_paths
    local jdtls = get_jdtls_module()
    if not jdtls then
        return
    end
    local jdtls_java = cached_jdtls_java
    local workspace_dir = get_workspace_dir(root_dir)
    repair_workspace_index_if_needed(workspace_dir)
    local detected_runtimes = cached_runtimes

    local config = {
        cmd = {
            jdtls_java, -- Use Java 17+ for JDTLS (auto-detected)
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=WARN",
            "-XX:+UseParallelGC",
            "-XX:GCTimeRatio=4",
            "-XX:AdaptiveSizePolicyWeight=90",
            "-Dsun.zip.disableMemoryMapping=true",
            "-Xlog:disable",
            "-javaagent:" .. paths.lombok_jar,
            "-Xms100m",
            "-Xmx4g",
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
        root_dir = root_dir,
        on_attach = function(client, bufnr)
            -- Setup CodeLens (Run/Debug buttons, reference counts)
            codelens.on_attach(client, bufnr)

            -- LSP Keybindings
            local opts = { buffer = bufnr, silent = true }

            -- CodeLens
            vim.keymap.set("n", "<Leader>cl", vim.lsp.codelens.run, vim.tbl_extend("force", opts, { desc = "Run CodeLens" }))

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
            vim.keymap.set("n", "<leader>jt", function()
                local startpath = vim.api.nvim_buf_get_name(bufnr)
                if not ensure_debug_ready(root_dir, startpath, "<leader>jt") then
                    return
                end
                require("jdtls").test_nearest_method()
            end, vim.tbl_extend("force", opts, { desc = "Test Nearest Method" }))
            vim.keymap.set("n", "<leader>jT", function()
                local startpath = vim.api.nvim_buf_get_name(bufnr)
                if not ensure_debug_ready(root_dir, startpath, "<leader>jT") then
                    return
                end
                require("jdtls").test_class()
            end, vim.tbl_extend("force", opts, { desc = "Test Class" }))
            vim.keymap.set("n", "<leader>jp", function()
                local startpath = vim.api.nvim_buf_get_name(bufnr)
                if not ensure_debug_ready(root_dir, startpath, "<leader>jp") then
                    return
                end
                require("jdtls").pick_test()
            end, vim.tbl_extend("force", opts, { desc = "Pick Test" }))

            -- Java Debug
            vim.keymap.set("n", "<leader>jd", function()
                local startpath = vim.api.nvim_buf_get_name(bufnr)
                if not ensure_debug_ready(root_dir, startpath, "<leader>jd") then
                    return
                end
                ensure_jdtls_dap(root_dir)
                require("jdtls.dap").setup_dap_main_class_configs()
                require("dap").continue()
            end, vim.tbl_extend("force", opts, { desc = "Debug Java" }))

            -- Run main class
            vim.keymap.set("n", "<leader>jr", function()
                local startpath = vim.api.nvim_buf_get_name(bufnr)
                if not ensure_debug_ready(root_dir, startpath, "<leader>jr") then
                    return
                end
                ensure_jdtls_dap(root_dir)
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
                autobuild = {
                    enabled = false,
                },
                eclipse = {
                    downloadSources = false,
                },
                configuration = {
                    detectJdksAtStart = false,
                    updateBuildConfiguration = "disabled",
                    workspaceCacheLimit = 180,
                    -- Register all detected Java runtimes so JDTLS knows about Java 11, 17, 21, etc.
                    runtimes = detected_runtimes,
                },
                import = {
                    exclusions = {
                        "**/node_modules/**",
                        "**/.git/**",
                        "**/.gradle/**",
                        "**/build/**",
                        "**/target/**",
                        "**/.idea/**",
                        "**/.settings/**",
                        "**/.metadata/**",
                    },
                    maven = {
                        enabled = true,
                    },
                },
                inlayHints = {
                    parameterNames = {
                        enabled = "all",
                    },
                },
                implementationsCodeLens = {
                    enabled = false,
                },
                referencesCodeLens = {
                    enabled = false,
                },
                format = {
                    enabled = true,
                },
                maven = {
                    downloadSources = false,
                    updateSnapshots = false,
                },
                sharedIndexes = {
                    enabled = "on",
                    location = get_shared_index_dir(),
                },
                project = {
                    resourceFilters = {
                        "node_modules",
                        ".git",
                        ".gradle",
                        ".idea",
                        ".settings",
                        "build",
                        "target",
                    },
                },
                -- Compile with project's specified Java version
                compile = {
                    nullAnalysis = {
                        mode = "disabled",
                    },
                },
            },
        },
        init_options = {
            bundles = debug_enabled_roots[root_dir] and ensure_debug_bundles() or {},
            extendedClientCapabilities = jdtls.extendedClientCapabilities,
        },
    }

    -- Defer the actual start_or_attach so the UI thread is not blocked by JVM spawn / IPC handshake.
    -- vim.schedule lets the current file-open finish rendering before we touch LSP.
    vim.schedule(function()
        jdtls.start_or_attach(config)
    end)
end

function M.prewarm(bufnr)
    local target = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(target) then
        return
    end

    vim.api.nvim_buf_call(target, function()
        setup_jdtls(vim.api.nvim_buf_get_name(target))
    end)
end

vim.api.nvim_create_augroup("JavaLSPGroup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = "JavaLSPGroup",
    pattern = "java",
    callback = function()
        setup_jdtls()
    end,
})

-- Warm caches after Neovim is idle so the first Java file open doesn't pay the detection cost.
vim.defer_fn(function()
    pcall(ensure_caches)
end, 2000)

return M
