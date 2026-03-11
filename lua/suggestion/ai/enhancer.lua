-- AI Suggestion Enhancer
-- Uses Claude to enhance and generate code suggestions
-- Optimized for minimal token usage with smart caching
local M = {}

local client = require("suggestion.ai.client")
local context_builder = require("suggestion.ai.context_builder")
local ai_cache = require("suggestion.ai.cache")

---Clean AI response
---@param suggestion string
---@return string
local function clean_response(suggestion)
    if not suggestion then return "" end
    -- Remove markdown code blocks
    suggestion = suggestion:gsub("^```%w*\n", ""):gsub("\n```$", "")
    suggestion = suggestion:gsub("^```%w*", ""):gsub("```$", "")
    return vim.trim(suggestion)
end

---Generate AI suggestion for a method
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param bufnr number|nil
---@return string|nil suggestion, string|nil error
function M.generate(method_name, return_type, params, bufnr)
    -- Build context
    local context = context_builder.build(method_name, return_type, params, bufnr)

    -- Check if we should skip AI (simple getter/setter)
    local skip, simple_result = ai_cache.should_skip_ai(method_name, context)
    if skip and simple_result then
        return simple_result, nil
    end

    -- Check cache (memory -> disk -> pattern)
    local cached, source = ai_cache.get(method_name, context)
    if cached then
        vim.notify(string.format("[AI] Cache hit (%s)", source), vim.log.levels.DEBUG)
        return cached, nil
    end

    -- Ensure client is ready
    if not client.ensure_initialized() then
        return nil, "AI client not initialized"
    end

    -- Build MINIMAL prompts
    local system_prompt = context_builder.build_system_prompt(context)
    local user_prompt = context_builder.format_prompt(context)

    -- Call Claude with minimal tokens
    local suggestion, err = client.complete(user_prompt, system_prompt, {
        max_tokens = 256,  -- Reduced from 512
        temperature = 0.1,  -- Lower for more deterministic
    })

    if err then
        return nil, err
    end

    if suggestion then
        suggestion = clean_response(suggestion)
        -- Store in cache (memory + disk + extract pattern)
        ai_cache.set(method_name, context, suggestion, 256)
    end

    return suggestion, nil
end

---Generate AI suggestion asynchronously
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param callback function Callback(suggestion, error)
---@param bufnr number|nil
function M.generate_async(method_name, return_type, params, callback, bufnr)
    -- Build context first (synchronous, fast)
    local context = context_builder.build(method_name, return_type, params, bufnr)

    -- Check if we should skip AI
    local skip, simple_result = ai_cache.should_skip_ai(method_name, context)
    if skip and simple_result then
        vim.schedule(function()
            callback(simple_result, nil)
        end)
        return
    end

    -- Check cache
    local cached, source = ai_cache.get(method_name, context)
    if cached then
        vim.schedule(function()
            vim.notify(string.format("[AI] Cache hit (%s)", source), vim.log.levels.DEBUG)
            callback(cached, nil)
        end)
        return
    end

    -- Ensure client is ready
    if not client.ensure_initialized() then
        vim.schedule(function()
            callback(nil, "AI client not initialized")
        end)
        return
    end

    -- Build MINIMAL prompts
    local system_prompt = context_builder.build_system_prompt(context)
    local user_prompt = context_builder.format_prompt(context)

    -- Call Claude asynchronously
    client.complete_async(user_prompt, system_prompt, function(suggestion, err)
        if err then
            callback(nil, err)
            return
        end

        if suggestion then
            suggestion = clean_response(suggestion)
            -- Store in cache
            ai_cache.set(method_name, context, suggestion, 256)
        end

        callback(suggestion, nil)
    end, {
        max_tokens = 256,
        temperature = 0.1,
    })
end

---Enhance existing suggestions with AI
---@param suggestions table[] Existing suggestions
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param bufnr number|nil
---@return table[] Enhanced suggestions
function M.enhance_suggestions(suggestions, method_name, return_type, params, bufnr)
    -- Generate AI suggestion
    local ai_suggestion, err = M.generate(method_name, return_type, params, bufnr)

    if err then
        vim.notify("[AI] " .. err, vim.log.levels.DEBUG)
        return suggestions
    end

    if ai_suggestion and ai_suggestion ~= "" then
        -- Add AI suggestion as highest priority
        table.insert(suggestions, 1, {
            body = ai_suggestion,
            score = 100,  -- Highest score
            source = "ai",
            template_id = "claude-generated",
        })
    end

    return suggestions
end

---Enhance suggestions asynchronously
---@param suggestions table[] Existing suggestions
---@param method_name string
---@param return_type string|nil
---@param params string|nil
---@param callback function Callback(enhanced_suggestions)
---@param bufnr number|nil
function M.enhance_suggestions_async(suggestions, method_name, return_type, params, callback, bufnr)
    M.generate_async(method_name, return_type, params, function(ai_suggestion, err)
        if err then
            vim.notify("[AI] " .. err, vim.log.levels.DEBUG)
            callback(suggestions)
            return
        end

        if ai_suggestion and ai_suggestion ~= "" then
            -- Add AI suggestion as highest priority
            table.insert(suggestions, 1, {
                body = ai_suggestion,
                score = 100,
                source = "ai",
                template_id = "claude-generated",
            })
        end

        callback(suggestions)
    end, bufnr)
end

---Clear cache
function M.clear_cache()
    ai_cache.clear_memory()
end

---Clear all caches (including disk)
function M.clear_all_cache()
    ai_cache.clear_all()
end

---Get cache stats
---@return table
function M.cache_stats()
    return ai_cache.stats()
end

return M
