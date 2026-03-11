-- Project Indexer
-- Intelligent code suggestions based on project-wide symbol analysis
local M = {}

local db_module = require("indexer.db")
local scanner_module = require("indexer.scanner")
local patterns_module = require("indexer.patterns")

---@class IndexerConfig
---@field enabled boolean Enable indexer
---@field languages string[] Languages to index
---@field cache_dir string Cache directory for database
---@field auto_index boolean Auto-index on file events
---@field git_aware boolean Use git for incremental updates

---@class Indexer
---@field config IndexerConfig Configuration
---@field db IndexerDB|nil Database instance
---@field scanner Scanner|nil Scanner instance
---@field patterns PatternMatcher|nil Pattern matcher instance
---@field project_root string|nil Current project root
---@field project_id number|nil Current project ID
---@field initialized boolean Whether indexer is initialized
local state = {
    config = {
        enabled = true,
        languages = { "java", "typescript", "javascript" },
        cache_dir = vim.fn.stdpath("cache") .. "/pvim/index",
        auto_index = true,
        git_aware = true,
    },
    db = nil,
    scanner = nil,
    patterns = nil,
    project_root = nil,
    project_id = nil,
    initialized = false,
}

---Get current project root
---@return string|nil Project root path
local function get_project_root()
    -- Try to find git root first
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if git_root and git_root ~= "" and vim.v.shell_error == 0 then
        return git_root
    end

    -- Fallback to current working directory
    return vim.fn.getcwd()
end

---Get current git HEAD
---@return string|nil Git HEAD hash
local function get_git_head()
    local head = vim.fn.systemlist("git rev-parse HEAD 2>/dev/null")[1]
    if head and head ~= "" and vim.v.shell_error == 0 then
        return head
    end
    return nil
end

---Initialize indexer for a project
---@param root string Project root path
local function init_project(root)
    if not state.config.enabled then return end

    -- Skip if already initialized for this project
    if state.initialized and state.project_root == root then return end

    -- Create database connection
    state.db = db_module.new(state.config.cache_dir)
    state.project_id = state.db:get_or_create_project(root)
    state.project_root = root

    -- Create scanner and pattern matcher
    state.scanner = scanner_module.new(state.db, state.project_id)
    state.patterns = patterns_module.new(state.db, state.project_id)

    state.initialized = true
end

---Check if project needs full re-index
---@return boolean
local function needs_full_index()
    if not state.db or not state.project_root then return true end

    local project = state.db:get_project(state.project_root)
    if not project then return true end
    if not project.last_indexed or project.last_indexed == 0 then return true end

    -- Check if git HEAD changed (if git aware)
    if state.config.git_aware then
        local current_head = get_git_head()
        if current_head and project.git_head ~= current_head then
            return true
        end
    end

    return false
end

---Index current project
---@param force boolean|nil Force full re-index
local function index_project(force)
    if not state.initialized then
        local root = get_project_root()
        if root then
            init_project(root)
        else
            return
        end
    end

    if force or needs_full_index() then
        -- Full index
        vim.notify("[Indexer] Indexing project...", vim.log.levels.INFO)
        local count = state.scanner:scan_project(state.project_root, state.config.languages)
        state.db:update_project_indexed(state.project_id, get_git_head())
        vim.notify(string.format("[Indexer] Indexed %d files", count), vim.log.levels.INFO)
    else
        -- Already indexed, no notification needed
        vim.notify("[Indexer] Using cached index", vim.log.levels.DEBUG)
    end
end

---Index a single file
---@param filepath string File path
---@param lang string Language
local function index_file(filepath, lang)
    if not state.initialized or not state.scanner then return end

    if state.scanner:scan_file(filepath, lang) then
        vim.notify(string.format("[Indexer] Indexed %s", vim.fn.fnamemodify(filepath, ":t")), vim.log.levels.DEBUG)
    end
end

---Setup autocmds for auto-indexing
local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("ProjectIndexer", { clear = true })

    -- Index on entering a new project
    vim.api.nvim_create_autocmd("DirChanged", {
        group = group,
        callback = function()
            local root = get_project_root()
            if root and root ~= state.project_root then
                init_project(root)
                index_project(false)
            end
        end,
    })

    -- Index on VimEnter (only if not already initialized via ft trigger)
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        callback = function()
            if state.initialized then return end
            vim.defer_fn(function()
                index_project(false)
            end, 1000) -- Delay to not block startup
        end,
    })

    -- Incremental index on file save
    if state.config.auto_index then
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = group,
            pattern = { "*.java", "*.ts", "*.tsx", "*.js", "*.jsx" },
            callback = function(ev)
                local filepath = ev.file
                local ext = vim.fn.fnamemodify(filepath, ":e")
                local lang_map = {
                    java = "java",
                    ts = "typescript",
                    tsx = "typescript",
                    js = "javascript",
                    jsx = "javascript",
                }
                local lang = lang_map[ext]
                if lang then
                    index_file(filepath, lang)
                end
            end,
        })
    end
end

---Get suggestions for a method signature
---@param method_name string Method name
---@param return_type string|nil Return type
---@param params string|nil Parameters
---@return table[] Suggestions
function M.get_suggestions(method_name, return_type, params)
    if not state.initialized or not state.patterns then
        return {}
    end

    local file = vim.fn.expand("%:p")
    return state.patterns:get_suggestions(method_name, return_type, params, file)
end

---Find variables matching a pattern
---@param pattern string Pattern to match
---@return table[] Variables
function M.find_variables(pattern)
    if not state.initialized or not state.db then
        return {}
    end
    return state.db:find_variables(state.project_id, pattern)
end

---Find functions matching a pattern
---@param pattern string Pattern to match
---@return table[] Functions
function M.find_functions(pattern)
    if not state.initialized or not state.db then
        return {}
    end
    return state.db:find_functions(state.project_id, pattern)
end

---Get variables in current file
---@return table[] Variables
function M.get_current_file_variables()
    if not state.initialized or not state.db then
        return {}
    end
    local file = vim.fn.expand("%:p")
    return state.db:get_file_variables(state.project_id, file)
end

---Manually trigger project indexing
---@param force boolean|nil Force full re-index
function M.index(force)
    index_project(force or false)
end

---Reindex current file
function M.reindex_current()
    local filepath = vim.fn.expand("%:p")
    local ext = vim.fn.fnamemodify(filepath, ":e")
    local lang_map = {
        java = "java",
        ts = "typescript",
        tsx = "typescript",
        js = "javascript",
        jsx = "javascript",
    }
    local lang = lang_map[ext]
    if lang then
        index_file(filepath, lang)
    end
end

---Get indexer status
---@return table Status information
function M.status()
    if not state.initialized then
        return { initialized = false }
    end

    local project = state.db:get_project(state.project_root)
    return {
        initialized = true,
        project_root = state.project_root,
        project_id = state.project_id,
        last_indexed = project and project.last_indexed or 0,
        git_head = project and project.git_head or nil,
    }
end

---Get database instance (for convention learning)
---@return IndexerDB|nil
function M.get_db()
    return state.db
end

---Get current project ID
---@return number|nil
function M.get_project_id()
    return state.project_id
end

---Setup indexer with configuration
---@param opts IndexerConfig|nil Configuration options
function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})

    if not state.config.enabled then
        return
    end

    -- Setup autocmds
    setup_autocmds()

    -- Initialize immediately if we're in a project
    -- This handles the case when plugin loads via ft trigger (after VimEnter)
    vim.schedule(function()
        local root = get_project_root()
        if root then
            init_project(root)
            index_project(false)
            vim.notify("[Indexer] Ready", vim.log.levels.INFO)
        end
    end)

    -- Register cmp source
    local cmp_ok, cmp_source = pcall(require, "indexer.cmp_source")
    if cmp_ok then
        cmp_source.register()
    end

    -- Create user commands
    vim.api.nvim_create_user_command("IndexProject", function(args)
        M.index(args.bang)
    end, { bang = true, desc = "Index current project (! to force)" })

    vim.api.nvim_create_user_command("IndexFile", function()
        M.reindex_current()
    end, { desc = "Reindex current file" })

    vim.api.nvim_create_user_command("IndexStatus", function()
        local status = M.status()
        if status.initialized then
            local last = status.last_indexed > 0
                and os.date("%Y-%m-%d %H:%M:%S", status.last_indexed)
                or "never"
            print(string.format(
                "Indexer: project=%s, id=%d, last_indexed=%s",
                status.project_root,
                status.project_id,
                last
            ))
        else
            print("Indexer: not initialized")
        end
    end, { desc = "Show indexer status" })
end

return M
