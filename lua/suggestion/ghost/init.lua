-- Ghost Text Controller
-- Main controller for Copilot-style ghost text suggestions
local M = {}

local renderer = require("suggestion.ghost.renderer")
local triggers = require("suggestion.ghost.triggers")

---@class GhostConfig
---@field enabled boolean Enable ghost text
---@field debounce_ms number Debounce time in milliseconds
---@field triggers string[] Enabled trigger types
---@field min_score number Minimum score for suggestions

-- Supported filetypes for suggestions
local SUPPORTED_FILETYPES = {
    java = true,
    typescript = true,
    typescriptreact = true,
    javascript = true,
    javascriptreact = true,
}

local state = {
    config = {
        enabled = true,
        debounce_ms = 500,  -- Longer debounce for less API spam
        triggers = { "method_body", "statement", "expression", "class_scaffold" },
        min_score = 20,
    },
    debounce_timer = nil,
    augroup = nil,
    initialized = false,
    pending_request = false,  -- Track if request is in flight
    last_trigger_time = 0,    -- Track last trigger for rate limiting
}

---Generate suggestions for a trigger
---@param trigger TriggerResult
---@param bufnr number
---@param callback function|nil Async callback(suggestions)
---@return table[]|nil (nil if async)
local function generate_suggestions(trigger, bufnr, callback)
    -- Get suggestion module
    local ok, suggestion = pcall(require, "suggestion")
    if not ok then
        if callback then
            callback({})
        end
        return {}
    end

    local suggestions = {}

    if trigger.type == "method_body" and trigger.method_name then
        -- Use existing suggestion system
        suggestions = suggestion.get_suggestions(
            trigger.method_name,
            trigger.return_type,
            nil,
            bufnr
        )

        -- Enhance with AI if available
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok and ai.is_ready() then
            if callback then
                -- Async AI enhancement
                ai.enhance_async(suggestions, trigger.method_name, trigger.return_type, nil, function(enhanced)
                    callback(enhanced)
                end, bufnr)
                return nil  -- Indicate async
            else
                -- Sync AI enhancement
                suggestions = ai.enhance(suggestions, trigger.method_name, trigger.return_type, nil, bufnr)
            end
        end
    elseif trigger.type == "line" or trigger.type == "assignment" or trigger.type == "return" or trigger.type == "method_call" then
        -- General line completion - use AI
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok and ai.is_ready() then
            local prompt_text = trigger.context.text or ""

            -- Build a context-aware method name for the AI
            local method_hint = "complete"
            if trigger.type == "assignment" then
                method_hint = "assign" .. (trigger.context.var_type or "Value")
            elseif trigger.type == "return" then
                method_hint = "returnValue"
            elseif trigger.type == "method_call" then
                method_hint = "call" .. (trigger.context.object or "")
                prompt_text = trigger.context.object .. "." .. (trigger.context.partial or "")
            end

            if callback then
                ai.generate_async(method_hint, nil, prompt_text, function(code, err)
                    if code and not err then
                        callback({{ body = code, score = 100, source = "ai" }})
                    else
                        callback({})
                    end
                end, bufnr)
                return nil
            else
                local code, err = ai.generate(method_hint, nil, prompt_text, bufnr)
                if code and not err then
                    suggestions = {{ body = code, score = 100, source = "ai" }}
                end
            end
        end
    elseif trigger.type == "class_scaffold" then
        -- Generate class scaffold with AI
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok and ai.is_ready() then
            local class_name = trigger.context.class_name
            if class_name then
                -- Generate scaffold prompt
                local scaffold_method = "scaffold" .. class_name
                if callback then
                    ai.generate_async(scaffold_method, nil, nil, function(code, err)
                        if code and not err then
                            callback({{ body = code, score = 100, source = "ai" }})
                        else
                            callback({})
                        end
                    end, bufnr)
                    return nil
                else
                    local code, err = ai.generate(scaffold_method, nil, nil, bufnr)
                    if code and not err then
                        suggestions = {{ body = code, score = 100, source = "ai" }}
                    end
                end
            end
        end
    elseif trigger.type == "statement" then
        -- Statement suggestions - use AI
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok and ai.is_ready() then
            local prev_var = trigger.context.prev_var
            if prev_var then
                local stmt_method = "useAfter" .. (prev_var:gsub("^%l", string.upper))
                if callback then
                    ai.generate_async(stmt_method, nil, nil, function(code, err)
                        if code and not err then
                            callback({{ body = code, score = 100, source = "ai" }})
                        else
                            callback({})
                        end
                    end, bufnr)
                    return nil
                else
                    local code, err = ai.generate(stmt_method, nil, nil, bufnr)
                    if code and not err then
                        suggestions = {{ body = code, score = 100, source = "ai" }}
                    end
                end
            end
        end
    elseif trigger.type == "expression" then
        -- Expression suggestions - use AI for method chains
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok and ai.is_ready() then
            local var = trigger.context.variable
            if var then
                local expr_method = "chainOn" .. (var:gsub("^%l", string.upper))
                if callback then
                    ai.generate_async(expr_method, nil, nil, function(code, err)
                        if code and not err then
                            callback({{ body = code, score = 100, source = "ai" }})
                        else
                            callback({})
                        end
                    end, bufnr)
                    return nil
                else
                    local code, err = ai.generate(expr_method, nil, nil, bufnr)
                    if code and not err then
                        suggestions = {{ body = code, score = 100, source = "ai" }}
                    end
                end
            end
        end
    end

    if callback then
        callback(suggestions)
    end
    return suggestions
end

---Handle text changed event
---@param bufnr number
local function on_text_changed(bufnr)
    -- Check master toggle first
    local master_ok, master = pcall(require, "suggestion.master")
    if master_ok and not master.is_enabled() then
        return
    end

    if not state.config.enabled then
        return
    end

    -- Skip if request already in flight (don't pile up requests)
    if state.pending_request then
        return
    end

    -- Check filetype
    local ft = vim.bo[bufnr].filetype
    local supported = ft == "java" or ft == "typescript" or ft == "typescriptreact"
        or ft == "javascript" or ft == "javascriptreact"

    if not supported then
        return
    end

    -- Detect trigger
    local trigger = triggers.detect(bufnr)

    if not trigger then
        return
    end

    -- Check if trigger type is enabled
    if not triggers.is_enabled(trigger.type, state.config.triggers) then
        return
    end

    -- Helper to show filtered suggestions
    local function show_suggestions(suggestions)
        state.pending_request = false

        if not suggestions or #suggestions == 0 then
            return
        end

        local filtered = {}
        for _, s in ipairs(suggestions) do
            if s.body and s.body ~= "" and (not s.score or s.score >= state.config.min_score) then
                table.insert(filtered, s)
            end
        end

        if #filtered > 0 then
            renderer.set_suggestions(filtered, bufnr)
        end
    end

    -- Mark request as pending
    state.pending_request = true

    -- Generate suggestions (async with AI)
    local result = generate_suggestions(trigger, bufnr, function(suggestions)
        -- Async callback from AI
        vim.schedule(function()
            show_suggestions(suggestions)
        end)
    end)

    -- If sync result, show immediately
    if result then
        show_suggestions(result)
    end
end

---Setup autocmds for ghost text
local function setup_autocmds()
    state.augroup = vim.api.nvim_create_augroup("SuggestionGhost", { clear = true })

    -- TextChangedI - trigger suggestions on typing
    vim.api.nvim_create_autocmd("TextChangedI", {
        group = state.augroup,
        callback = function(ev)
            -- Early exit checks (cheapest first)
            if not state.config.enabled then
                return
            end

            -- Check filetype (avoid processing unsupported files)
            local ft = vim.bo[ev.buf].filetype
            if not SUPPORTED_FILETYPES[ft] then
                return
            end

            -- Skip if request already in flight
            if state.pending_request then
                return
            end

            -- Rate limiting - minimum 200ms between triggers
            local now = vim.loop.now()
            if now - state.last_trigger_time < 200 then
                return
            end

            -- Debounce - reuse existing timer if possible
            if state.debounce_timer then
                vim.fn.timer_stop(state.debounce_timer)
                state.debounce_timer = nil
            end

            state.debounce_timer = vim.fn.timer_start(state.config.debounce_ms, function()
                state.debounce_timer = nil
                state.last_trigger_time = vim.loop.now()
                vim.schedule(function()
                    on_text_changed(ev.buf)
                end)
            end)
        end,
    })

    -- CursorMovedI - clear on cursor movement without typing
    vim.api.nvim_create_autocmd("CursorMovedI", {
        group = state.augroup,
        callback = function()
            -- Only clear if cursor moved significantly
            -- (debounce handles small movements from typing)
        end,
    })

    -- InsertLeave - clear ghost text
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = state.augroup,
        callback = function()
            renderer.clear()
        end,
    })

    -- BufLeave - clear ghost text
    vim.api.nvim_create_autocmd("BufLeave", {
        group = state.augroup,
        callback = function()
            renderer.clear()
        end,
    })

    -- BufDelete/BufUnload - cleanup buffer caches to prevent memory leaks
    vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
        group = state.augroup,
        callback = function(ev)
            triggers.clear_cache(ev.buf)
        end,
    })
end

---Setup keymaps for ghost text
local function setup_keymaps()
    -- Accept ghost text with Tab
    vim.keymap.set("i", "<Tab>", function()
        if renderer.is_visible() then
            if renderer.accept() then
                return ""
            end
        end
        -- Fall through to normal Tab behavior
        return "<Tab>"
    end, { expr = true, silent = true, desc = "Accept ghost text or Tab" })

    -- Next suggestion with Ctrl+]
    vim.keymap.set("i", "<C-]>", function()
        if renderer.is_visible() then
            renderer.next()
            return ""
        end
        return "<C-]>"
    end, { expr = true, silent = true, desc = "Next ghost suggestion" })

    -- Previous suggestion with Ctrl+[
    vim.keymap.set("i", "<C-[>", function()
        if renderer.is_visible() then
            renderer.prev()
            return ""
        end
        -- Note: Ctrl+[ is same as Escape, so be careful
        return "<C-[>"
    end, { expr = true, silent = true, desc = "Previous ghost suggestion" })

    -- Dismiss with Escape (handled by InsertLeave autocmd)
end

---Setup ghost text system
---@param opts GhostConfig|nil
function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})

    if not state.config.enabled then
        return
    end

    setup_autocmds()
    setup_keymaps()

    state.initialized = true
end

---Enable ghost text
function M.enable()
    state.config.enabled = true
end

---Disable ghost text
function M.disable()
    state.config.enabled = false
    -- Clean up timer to prevent memory leak
    if state.debounce_timer then
        vim.fn.timer_stop(state.debounce_timer)
        state.debounce_timer = nil
    end
    state.pending_request = false
    renderer.clear()
end

---Toggle ghost text
function M.toggle()
    if state.config.enabled then
        M.disable()
    else
        M.enable()
    end
end

---Manually trigger suggestions
function M.trigger()
    local bufnr = vim.api.nvim_get_current_buf()
    on_text_changed(bufnr)
end

---Accept current suggestion
---@return boolean success
function M.accept()
    return renderer.accept()
end

---Show next suggestion
function M.next()
    renderer.next()
end

---Show previous suggestion
function M.prev()
    renderer.prev()
end

---Clear ghost text
function M.clear()
    renderer.clear()
end

---Check if ghost text is visible
---@return boolean
function M.is_visible()
    return renderer.is_visible()
end

---Get status
---@return table
function M.status()
    return {
        enabled = state.config.enabled,
        initialized = state.initialized,
        visible = renderer.is_visible(),
        suggestion_count = renderer.get_count(),
        current_index = renderer.get_index(),
    }
end

return M
