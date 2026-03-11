-- Master Control for Suggestion System
-- Single toggle to enable/disable everything: indexing, suggestions, AI, ghost text
local M = {}

local STATE_FILE = vim.fn.stdpath("data") .. "/pvim_suggestion_enabled"

local state = {
    enabled = false,  -- Disabled by default
    initialized = false,
}

---Load saved state
local function load_state()
    if vim.fn.filereadable(STATE_FILE) == 1 then
        local content = vim.fn.readfile(STATE_FILE)
        if content and #content > 0 then
            state.enabled = content[1] == "1"
        end
    end
end

---Save state
local function save_state()
    vim.fn.writefile({ state.enabled and "1" or "0" }, STATE_FILE)
end

---Check if system is enabled
---@return boolean
function M.is_enabled()
    if not state.initialized then
        load_state()
        state.initialized = true
    end
    return state.enabled
end

---Enable the entire suggestion system
function M.enable()
    state.enabled = true
    save_state()

    -- Enable components
    local ghost_ok, ghost = pcall(require, "suggestion.ghost")
    if ghost_ok then ghost.enable() end

    local ai_ok, ai = pcall(require, "suggestion.ai")
    if ai_ok then ai.enable() end

    vim.notify("[Suggest] System ENABLED", vim.log.levels.INFO)
end

---Disable the entire suggestion system
function M.disable()
    state.enabled = false
    save_state()

    -- Disable components
    local ghost_ok, ghost = pcall(require, "suggestion.ghost")
    if ghost_ok then
        ghost.disable()
        ghost.clear()
    end

    local ai_ok, ai = pcall(require, "suggestion.ai")
    if ai_ok then ai.disable() end

    vim.notify("[Suggest] System DISABLED", vim.log.levels.INFO)
end

---Toggle the system
---@return boolean new_state
function M.toggle()
    if M.is_enabled() then
        M.disable()
    else
        M.enable()
    end
    return state.enabled
end

---Get status
---@return table
function M.status()
    return {
        enabled = M.is_enabled(),
    }
end

return M
