-- Database module for project indexer
-- Uses sqlite.lua for persistent storage
local M = {}

local sqlite = require("sqlite")
local Path = require("plenary.path")

---@class IndexerDB
---@field db table SQLite database instance
---@field cache_dir string Directory for database files
local IndexerDB = {}
IndexerDB.__index = IndexerDB

-- Schema version for migrations
local SCHEMA_VERSION = 2

-- SQL statements
local SCHEMA = [[
CREATE TABLE IF NOT EXISTS meta (
    key TEXT PRIMARY KEY,
    value TEXT
);

CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY,
    root TEXT UNIQUE NOT NULL,
    last_indexed INTEGER,
    git_head TEXT
);

CREATE TABLE IF NOT EXISTS variables (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    file TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT,
    scope TEXT,
    line INTEGER,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS functions (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    file TEXT NOT NULL,
    name TEXT NOT NULL,
    return_type TEXT,
    params TEXT,
    body_hash TEXT,
    body_template TEXT,
    line INTEGER,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS patterns (
    id INTEGER PRIMARY KEY,
    project_id INTEGER,
    trigger TEXT NOT NULL,
    context TEXT,
    suggestion TEXT NOT NULL,
    score INTEGER DEFAULT 0,
    source TEXT DEFAULT 'project',
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Suggestion system tables (v2)

CREATE TABLE IF NOT EXISTS templates (
    id INTEGER PRIMARY KEY,
    template_id TEXT UNIQUE,
    category TEXT NOT NULL,
    language TEXT NOT NULL,
    verb TEXT NOT NULL,
    template_body TEXT NOT NULL,
    context_requirements TEXT,
    priority INTEGER DEFAULT 50,
    usage_count INTEGER DEFAULT 0,
    source TEXT DEFAULT 'user',
    created_at INTEGER,
    project_id INTEGER,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS conventions (
    id INTEGER PRIMARY KEY,
    project_id INTEGER NOT NULL,
    convention_type TEXT NOT NULL,
    pattern TEXT NOT NULL,
    confidence REAL,
    examples TEXT,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_vars_project ON variables(project_id);
CREATE INDEX IF NOT EXISTS idx_vars_name ON variables(name);
CREATE INDEX IF NOT EXISTS idx_vars_file ON variables(file);
CREATE INDEX IF NOT EXISTS idx_funcs_project ON functions(project_id);
CREATE INDEX IF NOT EXISTS idx_funcs_name ON functions(name);
CREATE INDEX IF NOT EXISTS idx_funcs_file ON functions(file);
CREATE INDEX IF NOT EXISTS idx_patterns_trigger ON patterns(trigger);
CREATE INDEX IF NOT EXISTS idx_templates_category ON templates(category, language);
CREATE INDEX IF NOT EXISTS idx_conventions_project ON conventions(project_id);
]]

---Create a new database instance
---@param cache_dir string Cache directory path
---@return IndexerDB
function M.new(cache_dir)
    local self = setmetatable({}, IndexerDB)
    self.cache_dir = cache_dir

    -- Ensure cache directory exists
    Path:new(cache_dir):mkdir({ parents = true })

    -- Open/create database
    local db_path = cache_dir .. "/index.db"
    self.db = sqlite:open(db_path)

    -- Initialize schema
    self:_init_schema()

    return self
end

---Initialize database schema
function IndexerDB:_init_schema()
    -- Always run schema creation first (uses IF NOT EXISTS, so safe to repeat)
    self.db:execute(SCHEMA)

    -- Now check and update schema version using raw SQL (avoids schema cache issues)
    local version = self:_get_meta("schema_version")
    if not version or tonumber(version) < SCHEMA_VERSION then
        self:_set_meta("schema_version", tostring(SCHEMA_VERSION))
    end
end

---Get metadata value (uses raw SQL to avoid schema cache issues)
---@param key string
---@return string|nil
function IndexerDB:_get_meta(key)
    local result = self.db:eval("SELECT value FROM meta WHERE key = ?", { key })
    -- db:eval returns table for SELECT, boolean for other statements
    if type(result) == "table" and #result > 0 then
        return result[1].value
    end
    return nil
end

---Set metadata value (uses raw SQL to avoid schema cache issues)
---@param key string
---@param value string
function IndexerDB:_set_meta(key, value)
    self.db:eval("INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)", { key, value })
end

-- Project operations

---Get or create project
---@param root string Project root path
---@return number Project ID
function IndexerDB:get_or_create_project(root)
    local existing = self.db:select("projects", { where = { root = root } })
    if existing and #existing > 0 then
        return existing[1].id
    end

    self.db:insert("projects", {
        root = root,
        last_indexed = 0,
    })

    local result = self.db:select("projects", { where = { root = root } })
    return result[1].id
end

---Update project indexed time
---@param project_id number
---@param git_head string|nil
function IndexerDB:update_project_indexed(project_id, git_head)
    self.db:update("projects", {
        where = { id = project_id },
        set = {
            last_indexed = os.time(),
            git_head = git_head,
        },
    })
end

---Get project info
---@param root string
---@return table|nil
function IndexerDB:get_project(root)
    local result = self.db:select("projects", { where = { root = root } })
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

-- Variable operations

---Clear variables for a file
---@param project_id number
---@param file string
function IndexerDB:clear_file_variables(project_id, file)
    self.db:delete("variables", {
        where = { project_id = project_id, file = file },
    })
end

---Insert variable (uses raw SQL to handle special characters in type names)
---@param project_id number
---@param file string
---@param name string
---@param var_type string|nil
---@param scope string
---@param line number
function IndexerDB:insert_variable(project_id, file, name, var_type, scope, line)
    self.db:eval([[
        INSERT INTO variables (project_id, file, name, type, scope, line)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], { project_id, file, name, var_type or "", scope or "local", line })
end

---Find variables by name pattern
---@param project_id number
---@param pattern string SQL LIKE pattern
---@return table[]
function IndexerDB:find_variables(project_id, pattern)
    return self.db:select("variables", {
        where = { project_id = project_id },
        contains = { name = pattern },
    }) or {}
end

---Get variables in file
---@param project_id number
---@param file string
---@return table[]
function IndexerDB:get_file_variables(project_id, file)
    return self.db:select("variables", {
        where = { project_id = project_id, file = file },
    }) or {}
end

-- Function operations

---Clear functions for a file
---@param project_id number
---@param file string
function IndexerDB:clear_file_functions(project_id, file)
    self.db:delete("functions", {
        where = { project_id = project_id, file = file },
    })
end

---Insert function (uses raw SQL to handle special characters in params)
---@param project_id number
---@param file string
---@param name string
---@param return_type string|nil
---@param params string JSON array
---@param body_hash string|nil
---@param body_template string|nil
---@param line number
function IndexerDB:insert_function(project_id, file, name, return_type, params, body_hash, body_template, line)
    self.db:eval([[
        INSERT INTO functions (project_id, file, name, return_type, params, body_hash, body_template, line)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], { project_id, file, name, return_type or "", params or "", body_hash or "", body_template or "", line })
end

---Find functions by name pattern
---@param project_id number
---@param pattern string SQL LIKE pattern
---@return table[]
function IndexerDB:find_functions(project_id, pattern)
    return self.db:select("functions", {
        where = { project_id = project_id },
        contains = { name = pattern },
    }) or {}
end

---Get functions with similar names (for pattern learning)
---@param project_id number
---@param prefix string Function name prefix (e.g., "get", "calculate")
---@return table[]
function IndexerDB:get_functions_by_prefix(project_id, prefix)
    local sql = [[
        SELECT * FROM functions
        WHERE project_id = ? AND name LIKE ?
        ORDER BY name
    ]]
    return self.db:eval(sql, { project_id, prefix .. "%" }) or {}
end

-- Pattern operations

---Insert or update pattern
---@param project_id number|nil
---@param trigger string
---@param context string|nil JSON
---@param suggestion string
---@param source string 'project', 'claude', 'user'
function IndexerDB:upsert_pattern(project_id, trigger, context, suggestion, source)
    -- Check if pattern exists
    local existing = self.db:select("patterns", {
        where = { trigger = trigger, suggestion = suggestion },
    })

    if existing and #existing > 0 then
        -- Increment score
        self.db:update("patterns", {
            where = { id = existing[1].id },
            set = { score = existing[1].score + 1 },
        })
    else
        self.db:insert("patterns", {
            project_id = project_id,
            trigger = trigger,
            context = context,
            suggestion = suggestion,
            score = 1,
            source = source,
        })
    end
end

---Find patterns matching a trigger
---@param trigger string Function name to match
---@return table[]
function IndexerDB:find_patterns(trigger)
    -- Match exact or wildcard patterns
    local sql = [[
        SELECT * FROM patterns
        WHERE ? LIKE REPLACE(trigger, '*', '%')
        ORDER BY score DESC
        LIMIT 10
    ]]
    return self.db:eval(sql, { trigger }) or {}
end

---Get all patterns for a project
---@param project_id number
---@return table[]
function IndexerDB:get_project_patterns(project_id)
    return self.db:select("patterns", {
        where = { project_id = project_id },
        order_by = { desc = "score" },
    }) or {}
end

-- Cleanup

---Clear all data for a project
---@param project_id number
function IndexerDB:clear_project(project_id)
    self.db:delete("variables", { where = { project_id = project_id } })
    self.db:delete("functions", { where = { project_id = project_id } })
    self.db:delete("patterns", { where = { project_id = project_id } })
end

---Close database connection
function IndexerDB:close()
    if self.db then
        self.db:close()
        self.db = nil
    end
end

return M
