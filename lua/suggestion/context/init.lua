-- Context Module
-- Coordinates file analysis with caching
local M = {}

local file_analyzer = require("suggestion.context.file_analyzer")
local cache = require("suggestion.context.cache")

---Get file context for current buffer (with caching)
---@param bufnr number|nil Buffer number
---@return FileContext|nil
function M.get(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Try cache first
    local cached = cache.get(bufnr)
    if cached then
        return cached
    end

    -- Analyze file
    local context = file_analyzer.analyze(bufnr)
    if context then
        cache.set(bufnr, context)
    end

    return context
end

---Force refresh of file context
---@param bufnr number|nil Buffer number
---@return FileContext|nil
function M.refresh(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    cache.clear(bufnr)
    return M.get(bufnr)
end

---Clear context cache
---@param bufnr number|nil Buffer number (nil = all buffers)
function M.clear_cache(bufnr)
    if bufnr then
        cache.clear(bufnr)
    else
        cache.clear_all()
    end
end

-- Re-export useful functions from file_analyzer
M.find_field_by_type = file_analyzer.find_field_by_type
M.get_dependencies = file_analyzer.get_dependencies
M.has_method = file_analyzer.has_method
M.infer_entity = file_analyzer.infer_entity

return M
