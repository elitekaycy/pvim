-- AI Module
-- Coordinates Claude integration for intelligent code suggestions
local M = {}

local client = require("suggestion.ai.client")
local enhancer = require("suggestion.ai.enhancer")
local context_builder = require("suggestion.ai.context_builder")

---@class AIConfig
---@field enabled boolean Enable AI suggestions
---@field model string Claude model to use
---@field enhance_always boolean Always enhance with AI
---@field fallback_threshold number Use AI when template score below this

local state = {
    config = {
        enabled = true,
        model = "claude-sonnet-4-20250514",
        enhance_always = true,
        fallback_threshold = 50,
    },
    initialized = false,
}

---Setup AI module
---@param opts AIConfig|nil
function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})

    if not state.config.enabled then
        return
    end

    -- Initialize client with model preference
    -- Don't prompt for API key immediately - wait until first use
    state.initialized = true
end

---Initialize AI (prompt for API key if needed)
---@return boolean success
function M.init()
    if not state.config.enabled then
        return false
    end

    return client.init({
        model = state.config.model,
    })
end

---Check if AI is enabled and ready
---@return boolean
function M.is_ready()
    return state.config.enabled and client.is_initialized()
end

---Generate AI suggestion
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param bufnr number|nil
---@return string|nil suggestion, string|nil error
function M.generate(method_name, return_type, params, bufnr)
    if not state.config.enabled then
        return nil, "AI is disabled"
    end

    return enhancer.generate(method_name, return_type, params, bufnr)
end

---Generate AI suggestion asynchronously
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param callback function
---@param bufnr number|nil
function M.generate_async(method_name, return_type, params, callback, bufnr)
    if not state.config.enabled then
        vim.schedule(function()
            callback(nil, "AI is disabled")
        end)
        return
    end

    enhancer.generate_async(method_name, return_type, params, callback, bufnr)
end

---Enhance suggestions with AI
---@param suggestions table[]
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param bufnr number|nil
---@return table[]
function M.enhance(suggestions, method_name, return_type, params, bufnr)
    if not state.config.enabled then
        return suggestions
    end

    -- Check if we should enhance
    local should_enhance = state.config.enhance_always

    if not should_enhance then
        -- Check if best template score is below threshold
        local best_score = 0
        for _, s in ipairs(suggestions) do
            if s.score and s.score > best_score then
                best_score = s.score
            end
        end
        should_enhance = best_score < state.config.fallback_threshold
    end

    if should_enhance then
        return enhancer.enhance_suggestions(suggestions, method_name, return_type, params, bufnr)
    end

    return suggestions
end

---Enhance suggestions asynchronously
---@param suggestions table[]
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param callback function
---@param bufnr number|nil
function M.enhance_async(suggestions, method_name, return_type, params, callback, bufnr)
    if not state.config.enabled then
        vim.schedule(function()
            callback(suggestions)
        end)
        return
    end

    local should_enhance = state.config.enhance_always

    if not should_enhance then
        local best_score = 0
        for _, s in ipairs(suggestions) do
            if s.score and s.score > best_score then
                best_score = s.score
            end
        end
        should_enhance = best_score < state.config.fallback_threshold
    end

    if should_enhance then
        enhancer.enhance_suggestions_async(suggestions, method_name, return_type, params, callback, bufnr)
    else
        vim.schedule(function()
            callback(suggestions)
        end)
    end
end

---Build context for debugging
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param bufnr number|nil
---@return table
function M.build_context(method_name, return_type, params, bufnr)
    return context_builder.build(method_name, return_type, params, bufnr)
end

---Format context as prompt string
---@param context table
---@return string
function M.format_context(context)
    return context_builder.format_prompt(context)
end

---Set model
---@param model string
function M.set_model(model)
    client.set_model(model)  -- Handles shortcuts
    state.config.model = client.get_model()  -- Get actual model name
end

---Get current model
---@return string
function M.get_model()
    return client.get_model()
end

---Enable AI
function M.enable()
    state.config.enabled = true
end

---Disable AI
function M.disable()
    state.config.enabled = false
end

---Toggle AI
function M.toggle()
    state.config.enabled = not state.config.enabled
end

---Clear API key (re-auth)
function M.clear_auth()
    client.clear_auth()
end

---Clear suggestion cache (memory only)
function M.clear_cache()
    enhancer.clear_cache()
end

---Clear all caches (memory + disk)
function M.clear_all_cache()
    enhancer.clear_all_cache()
end

---Get cache statistics
---@return table
function M.cache_stats()
    return enhancer.cache_stats()
end

---Get status
---@return table
function M.status()
    local client_status = client.status()
    local cache_stats = enhancer.cache_stats()

    return {
        enabled = state.config.enabled,
        initialized = state.initialized,
        client_ready = client_status.initialized,
        model = state.config.model,
        enhance_always = state.config.enhance_always,
        fallback_threshold = state.config.fallback_threshold,
        -- Cache stats
        cache_memory = cache_stats.memory_entries,
        cache_disk = cache_stats.disk_entries,
        cache_patterns = cache_stats.pattern_entries,
        cache_hits = cache_stats.hits,
        cache_misses = cache_stats.misses,
        pattern_hits = cache_stats.pattern_hits,
        saved_tokens = cache_stats.saved_tokens,
        hit_rate = cache_stats.hit_rate,
    }
end

return M
