-- Scanner module for project indexer
-- Uses treesitter to extract symbols from source files
local M = {}

local Path = require("plenary.path")

---@class Scanner
---@field db IndexerDB Database instance
---@field project_id number Current project ID
---@field queries table Language-specific query modules
local Scanner = {}
Scanner.__index = Scanner

---Create a new scanner instance
---@param db IndexerDB Database instance
---@param project_id number Project ID
---@return Scanner
function M.new(db, project_id)
    local self = setmetatable({}, Scanner)
    self.db = db
    self.project_id = project_id
    self.queries = {}
    return self
end

---Get or load query module for a language
---@param lang string Language name
---@return table|nil Query module
function Scanner:get_query_module(lang)
    if self.queries[lang] then
        return self.queries[lang]
    end

    local ok, query_module = pcall(require, "indexer.queries." .. lang)
    if ok then
        self.queries[lang] = query_module
        return query_module
    end

    return nil
end

---Check if a language is supported
---@param lang string Language name
---@return boolean
function Scanner:supports_language(lang)
    return self:get_query_module(lang) ~= nil
end

---Scan a single file
---@param filepath string Absolute file path
---@param lang string Language name
---@return boolean Success
function Scanner:scan_file(filepath, lang)
    local query_module = self:get_query_module(lang)
    if not query_module then
        return false
    end

    -- Read file content
    local path = Path:new(filepath)
    if not path:exists() then
        return false
    end

    local content = path:read()
    if not content or content == "" then
        return false
    end

    -- Parse with treesitter
    local parser = vim.treesitter.get_string_parser(content, lang)
    if not parser then
        return false
    end

    local tree = parser:parse()[1]
    if not tree then
        return false
    end

    local root = tree:root()

    -- Clear existing data for this file
    self.db:clear_file_variables(self.project_id, filepath)
    self.db:clear_file_functions(self.project_id, filepath)

    -- Extract variables
    if query_module.variable_query then
        self:extract_variables(filepath, content, root, lang, query_module.variable_query)
    end

    -- Extract functions
    if query_module.function_query then
        self:extract_functions(filepath, content, root, lang, query_module.function_query)
    end

    return true
end

---Extract variables from AST
---@param filepath string File path
---@param content string File content
---@param root TSNode Root node
---@param lang string Language
---@param query_str string Treesitter query string
function Scanner:extract_variables(filepath, content, root, lang, query_str)
    local ok, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not ok then
        return
    end

    for _, match, _ in query:iter_matches(root, content, 0, -1) do
        local name, var_type, scope, line

        for id, nodes in pairs(match) do
            -- Handle both old API (single node) and new API (table of nodes)
            local node = type(nodes) == "table" and nodes[1] or nodes
            if not node or not node.start then goto continue end

            local capture_name = query.captures[id]
            local node_ok, node_text = pcall(vim.treesitter.get_node_text, node, content)
            if not node_ok then goto continue end

            if capture_name == "name" then
                name = node_text
                line = node:start() + 1
            elseif capture_name == "type" then
                var_type = node_text
            elseif capture_name == "scope" then
                scope = node_text
            end

            ::continue::
        end

        if name then
            self.db:insert_variable(
                self.project_id,
                filepath,
                name,
                var_type,
                scope or "local",
                line or 0
            )
        end
    end
end

---Extract functions from AST
---@param filepath string File path
---@param content string File content
---@param root TSNode Root node
---@param lang string Language
---@param query_str string Treesitter query string
function Scanner:extract_functions(filepath, content, root, lang, query_str)
    local ok, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not ok then
        return
    end

    for _, match, _ in query:iter_matches(root, content, 0, -1) do
        local name, return_type, params, body, line

        for id, nodes in pairs(match) do
            -- Handle both old API (single node) and new API (table of nodes)
            local node = type(nodes) == "table" and nodes[1] or nodes
            if not node or not node.start then goto continue end

            local capture_name = query.captures[id]
            local node_ok, node_text = pcall(vim.treesitter.get_node_text, node, content)
            if not node_ok then goto continue end

            if capture_name == "name" then
                name = node_text
                line = node:start() + 1
            elseif capture_name == "return_type" then
                return_type = node_text
            elseif capture_name == "params" then
                params = node_text
            elseif capture_name == "body" then
                body = node_text
            end

            ::continue::
        end

        if name then
            -- Generate body hash for pattern matching
            local body_hash = body and vim.fn.sha256(body) or nil

            -- Generate body template (simplified for now)
            local body_template = body and self:normalize_body(body) or nil

            self.db:insert_function(
                self.project_id,
                filepath,
                name,
                return_type,
                params,
                body_hash,
                body_template,
                line or 0
            )
        end
    end
end

---Normalize function body for pattern matching
---@param body string Function body
---@return string Normalized template
function Scanner:normalize_body(body)
    -- Remove comments
    local normalized = body:gsub("//[^\n]*", "")
    normalized = normalized:gsub("/%*.-*/", "")

    -- Normalize whitespace
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("^%s*", "")
    normalized = normalized:gsub("%s*$", "")

    -- Truncate if too long
    if #normalized > 500 then
        normalized = normalized:sub(1, 500) .. "..."
    end

    return normalized
end

---Scan all files in a directory matching given patterns
---@param root_dir string Root directory path
---@param patterns table File patterns (e.g., {"*.java", "*.ts"})
---@param lang_map table Map of extension to language (e.g., {java = "java", ts = "typescript"})
---@return number Number of files scanned
function Scanner:scan_directory(root_dir, patterns, lang_map)
    local count = 0

    for _, pattern in ipairs(patterns) do
        local files = vim.fn.globpath(root_dir, "**/" .. pattern, false, true)

        for _, filepath in ipairs(files) do
            -- Skip node_modules, .git, build directories
            if not filepath:match("/node_modules/")
                and not filepath:match("/.git/")
                and not filepath:match("/build/")
                and not filepath:match("/target/")
                and not filepath:match("/dist/")
            then
                local ext = vim.fn.fnamemodify(filepath, ":e")
                local lang = lang_map[ext]

                if lang and self:scan_file(filepath, lang) then
                    count = count + 1
                end
            end
        end
    end

    return count
end

---Scan a project
---@param root_dir string Project root directory
---@param languages table List of languages to scan
---@return number Number of files scanned
function Scanner:scan_project(root_dir, languages)
    local patterns = {}
    local lang_map = {}

    -- Build patterns and lang map based on requested languages
    local lang_config = {
        java = { patterns = { "*.java" }, ext_map = { java = "java" } },
        typescript = { patterns = { "*.ts", "*.tsx" }, ext_map = { ts = "typescript", tsx = "typescript" } },
        javascript = { patterns = { "*.js", "*.jsx" }, ext_map = { js = "javascript", jsx = "javascript" } },
        lua = { patterns = { "*.lua" }, ext_map = { lua = "lua" } },
    }

    for _, lang in ipairs(languages) do
        local config = lang_config[lang]
        if config then
            for _, p in ipairs(config.patterns) do
                table.insert(patterns, p)
            end
            for ext, l in pairs(config.ext_map) do
                lang_map[ext] = l
            end
        end
    end

    return self:scan_directory(root_dir, patterns, lang_map)
end

return M
