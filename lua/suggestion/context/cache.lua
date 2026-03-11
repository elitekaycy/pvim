-- Context Cache
-- Buffer-local caching with TTL for file context
local M = {}

-- Cache TTL in seconds
local CACHE_TTL = 5

---@class CachedContext
---@field context FileContext The cached context
---@field timestamp number When the cache was created
---@field changedtick number Buffer changedtick when cached

---Get cached context for a buffer
---@param bufnr number Buffer number
---@return FileContext|nil
function M.get(bufnr)
    local cache = vim.b[bufnr].suggestion_context_cache
    if not cache then
        return nil
    end

    -- Check if cache is stale by time
    if os.time() - cache.timestamp > CACHE_TTL then
        return nil
    end

    -- Check if buffer changed
    local current_tick = vim.api.nvim_buf_get_changedtick(bufnr)
    if cache.changedtick ~= current_tick then
        return nil
    end

    return cache.context
end

---Set cached context for a buffer
---@param bufnr number Buffer number
---@param context FileContext Context to cache
function M.set(bufnr, context)
    vim.b[bufnr].suggestion_context_cache = {
        context = context,
        timestamp = os.time(),
        changedtick = vim.api.nvim_buf_get_changedtick(bufnr),
    }
end

---Clear cache for a buffer
---@param bufnr number Buffer number
function M.clear(bufnr)
    vim.b[bufnr].suggestion_context_cache = nil
end

---Clear all caches
function M.clear_all()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) then
            vim.b[buf].suggestion_context_cache = nil
        end
    end
end

return M
