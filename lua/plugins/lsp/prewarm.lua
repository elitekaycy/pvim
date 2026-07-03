local M = {}

local warmed_roots = {}
local active_hidden_buffers = {}

local function has_client(name, root_dir)
    for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
        if client.config and client.config.root_dir == root_dir then
            return true
        end
    end
    return false
end

local function load_hidden_buffer(path)
    if not path or path == "" or vim.fn.filereadable(path) == 0 then
        return nil
    end

    local group = vim.api.nvim_create_augroup("PvimLspPrewarmSwap", { clear = true })
    local autocmd = vim.api.nvim_create_autocmd("SwapExists", {
        group = group,
        callback = function()
            vim.v.swapchoice = "q"
        end,
    })

    local bufnr = vim.fn.bufadd(path)
    local ok = pcall(vim.fn.bufload, bufnr)
    pcall(vim.api.nvim_del_autocmd, autocmd)
    pcall(vim.api.nvim_del_augroup_by_id, group)

    if not ok or vim.fn.bufloaded(bufnr) == 0 then
        return nil
    end

    pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = bufnr })
    pcall(vim.api.nvim_set_option_value, "buflisted", false, { buf = bufnr })
    active_hidden_buffers[bufnr] = path
    return bufnr
end

local function create_hidden_path_buffer(path, filetype)
    if not path or path == "" then
        return nil
    end

    local bufnr = vim.api.nvim_create_buf(false, false)
    if not bufnr or bufnr == 0 then
        return nil
    end

    pcall(vim.api.nvim_set_option_value, "swapfile", false, { buf = bufnr })
    pcall(vim.api.nvim_set_option_value, "bufhidden", "hide", { buf = bufnr })
    pcall(vim.api.nvim_set_option_value, "buflisted", false, { buf = bufnr })
    pcall(vim.api.nvim_buf_set_name, bufnr, path)
    if filetype and filetype ~= "" then
        pcall(vim.api.nvim_set_option_value, "filetype", filetype, { buf = bufnr })
    end
    active_hidden_buffers[bufnr] = path
    return bufnr
end

local function first_readable(paths)
    for _, path in ipairs(paths) do
        if path and path ~= "" and vim.fn.filereadable(path) == 1 then
            return path
        end
    end
    return nil
end

local function glob_candidates(root, patterns, limit)
    local results = {}

    for _, pattern in ipairs(patterns) do
        local matches = vim.fn.globpath(root, pattern, false, true)
        for _, path in ipairs(matches) do
            if path and path ~= "" and vim.fn.filereadable(path) == 1 then
                table.insert(results, path)
                if #results >= limit then
                    return results
                end
            end
        end
    end

    return results
end

local function score_java_candidate(path)
    local score = 0
    local lower = path:lower()

    if lower:match("application%.java$") then score = score + 100 end
    if lower:match("/docs/") then score = score + 70 end
    if lower:match("/config/") then score = score + 50 end
    if lower:match("dto%.java$") then score = score + 40 end
    if lower:match("request%.java$") or lower:match("response%.java$") then score = score + 30 end
    if lower:match("interface%.java$") then score = score + 20 end

    if lower:match("/test/") then score = score - 80 end
    if lower:match("/mapper/") or lower:match("mapper%.java$") then score = score - 120 end
    if lower:match("/entity/") or lower:match("entity%.java$") then score = score - 40 end
    if lower:match("generated") then score = score - 200 end

    return score
end

local function sort_java_candidates(paths)
    table.sort(paths, function(a, b)
        local sa = score_java_candidate(a)
        local sb = score_java_candidate(b)
        if sa == sb then
            return a < b
        end
        return sa > sb
    end)
    return paths
end

local function score_ts_candidate(path)
    local score = 0
    local lower = path:lower()

    if lower:match("/src/index%.ts$") or lower:match("/src/index%.tsx$") then score = score + 100 end
    if lower:match("/app/") then score = score + 40 end
    if lower:match("/components/") then score = score + 20 end

    if lower:match("%.test%.ts$") or lower:match("%.spec%.ts$") then score = score - 120 end
    if lower:match("/test/") or lower:match("/tests/") then score = score - 120 end
    if lower:match("/dist/") or lower:match("/build/") then score = score - 200 end
    if lower:match("%.d%.ts$") then score = score - 80 end

    return score
end

local function sort_ts_candidates(paths)
    table.sort(paths, function(a, b)
        local sa = score_ts_candidate(a)
        local sb = score_ts_candidate(b)
        if sa == sb then
            return a < b
        end
        return sa > sb
    end)
    return paths
end

local function detect_java_project(root)
    local markers = {
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "mvnw",
        "gradlew",
        ".mvn",
        "settings.gradle",
        "settings.gradle.kts",
    }
    local found = vim.fs.find(markers, { path = root, upward = false, limit = 1 })
    return #found > 0
end

local function detect_ts_project(root)
    local markers = {
        "tsconfig.json",
        "jsconfig.json",
        "package.json",
    }
    local found = vim.fs.find(markers, { path = root, upward = false, limit = 1 })
    return #found > 0
end

local function has_non_java_user_file_buffer()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            if not active_hidden_buffers[bufnr] then
                local name = vim.api.nvim_buf_get_name(bufnr)
                local buftype = vim.bo[bufnr].buftype
                local filetype = vim.bo[bufnr].filetype
                if name ~= "" and buftype == "" and filetype ~= "java" then
                    return true
                end
            end
        end
    end

    return false
end

local function prewarm_java(root)
    if has_client("jdtls", root) then
        return
    end

    local files = sort_java_candidates(glob_candidates(root, {
        "src/main/java/**/*.java",
        "src/test/java/**/*.java",
        "**/*.java",
    }, 40))

    for _, file in ipairs(files) do
        local bufnr = create_hidden_path_buffer(file, "java")
        if bufnr then
            pcall(function()
                require("lazy").load({ plugins = { "nvim-lspconfig", "nvim-jdtls" } })
                vim.api.nvim_buf_call(bufnr, function()
                    require("plugins.lsp.servers.java").prewarm(bufnr)
                end)
            end)
            return
        end
    end
end

local function prewarm_ts(root)
    if has_client("ts_ls", root) then
        return
    end

    local files = sort_ts_candidates(glob_candidates(root, {
        "src/**/*.ts",
        "src/**/*.tsx",
        "app/**/*.ts",
        "app/**/*.tsx",
        "packages/*/src/**/*.ts",
        "packages/*/src/**/*.tsx",
        "**/*.ts",
        "**/*.tsx",
    }, 40))

    for _, file in ipairs(files) do
        if not file:match("/node_modules/") and not file:match("/dist/") and not file:match("/build/") then
            local bufnr = create_hidden_path_buffer(file, "typescript")
            if bufnr then
                pcall(function()
                    require("lazy").load({ plugins = { "nvim-lspconfig" } })
                    vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
                end)
                return
            end
        end
    end
end

local function maybe_prewarm(force)
    local cwd = vim.fs.normalize(vim.fn.getcwd())
    if warmed_roots[cwd] then
        return
    end

    if not force and has_non_java_user_file_buffer() then
        return
    end

    warmed_roots[cwd] = true

    vim.schedule(function()
        if detect_java_project(cwd) then
            prewarm_java(cwd)
        end

        if detect_ts_project(cwd) then
            prewarm_ts(cwd)
        end
    end)
end

function M.trigger()
    local cwd = vim.fs.normalize(vim.fn.getcwd())
    warmed_roots[cwd] = nil
    maybe_prewarm(true)
end

function M.status()
    local cwd = vim.fs.normalize(vim.fn.getcwd())
    local clients = vim.tbl_map(function(c)
        return {
            name = c.name,
            root_dir = c.config and c.config.root_dir or nil,
        }
    end, vim.lsp.get_clients())

    local hidden = {}
    for bufnr, path in pairs(active_hidden_buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
            table.insert(hidden, { bufnr = bufnr, path = path })
        else
            active_hidden_buffers[bufnr] = nil
        end
    end

    return {
        cwd = cwd,
        warmed = warmed_roots[cwd] == true,
        clients = clients,
        hidden_buffers = hidden,
    }
end

function M.setup()
    local group = vim.api.nvim_create_augroup("PvimLspPrewarm", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function()
            vim.defer_fn(maybe_prewarm, 150)
        end,
    })

    vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
            vim.defer_fn(maybe_prewarm, 150)
        end,
    })

    vim.api.nvim_create_user_command("LspPrewarm", function()
        M.trigger()
        vim.notify("LSP prewarm triggered for " .. vim.fn.getcwd(), vim.log.levels.INFO)
    end, { desc = "Trigger background LSP prewarm for current project" })

    vim.api.nvim_create_user_command("LspPrewarmStatus", function()
        local status = M.status()
        vim.print(status)
    end, { desc = "Show background LSP prewarm status" })
end

return M
