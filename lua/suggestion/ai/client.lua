-- Anthropic API Client
-- Handles authentication and requests to Claude API
-- Optimized for minimal token usage
local M = {}

local curl = require("plenary.curl")

-- API configuration
local API_URL = "https://api.anthropic.com/v1/messages"
local API_VERSION = "2023-06-01"

-- Models (use Haiku for speed/cost, Sonnet for complex)
local MODELS = {
    fast = "claude-3-5-haiku-20241022",  -- Fast, cheap
    smart = "claude-sonnet-4-20250514",   -- Better quality
}
local DEFAULT_MODEL = MODELS.fast  -- Default to fast model
local MAX_TOKENS = 256  -- Reduced from 1024

-- State
local state = {
    api_key = nil,
    model = DEFAULT_MODEL,
    initialized = false,
}

---Prompt user for API key
---@return string|nil
local function prompt_for_api_key()
    -- Try environment variable first
    local env_key = os.getenv("ANTHROPIC_API_KEY")
    if env_key and env_key ~= "" then
        return env_key
    end

    -- Try config file
    local config_path = vim.fn.expand("~/.config/anthropic/api_key")
    if vim.fn.filereadable(config_path) == 1 then
        local content = vim.fn.readfile(config_path)
        if content and #content > 0 then
            local key = vim.trim(content[1])
            if key ~= "" then
                return key
            end
        end
    end

    -- Prompt user
    local key = vim.fn.input({
        prompt = "Enter Anthropic API Key: ",
        default = "",
        cancelreturn = nil,
    })

    if key and key ~= "" then
        -- Offer to save
        local save = vim.fn.confirm("Save API key to ~/.config/anthropic/api_key?", "&Yes\n&No", 2)
        if save == 1 then
            vim.fn.mkdir(vim.fn.expand("~/.config/anthropic"), "p")
            vim.fn.writefile({ key }, config_path)
            vim.fn.system("chmod 600 " .. config_path)
        end
        return key
    end

    return nil
end

---Initialize the client
---@param opts table|nil Options
---@return boolean success
function M.init(opts)
    opts = opts or {}

    if opts.model then
        state.model = opts.model
    end

    -- Get API key
    if opts.api_key then
        state.api_key = opts.api_key
    else
        state.api_key = prompt_for_api_key()
    end

    if not state.api_key then
        vim.notify("[AI] No API key provided", vim.log.levels.WARN)
        return false
    end

    state.initialized = true
    vim.notify("[AI] Claude integration ready", vim.log.levels.INFO)
    return true
end

---Try to load API key from environment or config file (no prompts)
---@return boolean
local function try_load_key()
    if state.api_key then
        return true
    end

    -- Try environment variable
    local env_key = os.getenv("ANTHROPIC_API_KEY")
    if env_key and env_key ~= "" then
        state.api_key = env_key
        state.initialized = true
        return true
    end

    -- Try config file
    local config_path = vim.fn.expand("~/.config/anthropic/api_key")
    if vim.fn.filereadable(config_path) == 1 then
        local content = vim.fn.readfile(config_path)
        if content and #content > 0 then
            local key = vim.trim(content[1])
            if key ~= "" then
                state.api_key = key
                state.initialized = true
                return true
            end
        end
    end

    return false
end

---Check if client is initialized
---@return boolean
function M.is_initialized()
    -- Try to auto-load key if not initialized
    if not state.initialized then
        try_load_key()
    end
    return state.initialized and state.api_key ~= nil
end

---Ensure client is initialized
---@return boolean
function M.ensure_initialized()
    if M.is_initialized() then
        return true
    end
    return M.init()
end

---Make a request to Claude API
---@param messages table[] Messages array
---@param system string|nil System prompt
---@param opts table|nil Options (max_tokens, temperature)
---@return table|nil response, string|nil error
function M.request(messages, system, opts)
    if not M.ensure_initialized() then
        return nil, "API client not initialized"
    end

    opts = opts or {}

    local body = {
        model = opts.model or state.model,
        max_tokens = opts.max_tokens or MAX_TOKENS,
        messages = messages,
    }

    if system then
        body.system = system
    end

    if opts.temperature then
        body.temperature = opts.temperature
    end

    local response = curl.post(API_URL, {
        headers = {
            ["Content-Type"] = "application/json",
            ["x-api-key"] = state.api_key,
            ["anthropic-version"] = API_VERSION,
        },
        body = vim.json.encode(body),
        timeout = opts.timeout or 30000,
    })

    if response.status ~= 200 then
        local error_msg = "API request failed: " .. tostring(response.status)
        if response.body then
            local ok, decoded = pcall(vim.json.decode, response.body)
            if ok and decoded.error then
                error_msg = error_msg .. " - " .. (decoded.error.message or "Unknown error")
            end
        end
        return nil, error_msg
    end

    local ok, decoded = pcall(vim.json.decode, response.body)
    if not ok then
        return nil, "Failed to decode response"
    end

    return decoded, nil
end

---Simple completion request
---@param prompt string User prompt
---@param system string|nil System prompt
---@param opts table|nil Options
---@return string|nil content, string|nil error
function M.complete(prompt, system, opts)
    local messages = {
        { role = "user", content = prompt }
    }

    local response, err = M.request(messages, system, opts)
    if err then
        return nil, err
    end

    if response and response.content and #response.content > 0 then
        return response.content[1].text, nil
    end

    return nil, "No content in response"
end

---Async completion request (non-blocking)
---@param prompt string User prompt
---@param system string|nil System prompt
---@param callback function Callback(content, error)
---@param opts table|nil Options
function M.complete_async(prompt, system, callback, opts)
    if not M.ensure_initialized() then
        vim.schedule(function()
            callback(nil, "API client not initialized")
        end)
        return
    end

    opts = opts or {}

    local body = {
        model = opts.model or state.model,
        max_tokens = opts.max_tokens or MAX_TOKENS,
        messages = {{ role = "user", content = prompt }},
    }

    if system then
        body.system = system
    end

    if opts.temperature then
        body.temperature = opts.temperature
    end

    -- Use plenary async job for non-blocking request
    local Job = require("plenary.job")

    local json_body = vim.json.encode(body)

    Job:new({
        command = "curl",
        args = {
            "-s",
            "-X", "POST",
            API_URL,
            "-H", "Content-Type: application/json",
            "-H", "x-api-key: " .. state.api_key,
            "-H", "anthropic-version: " .. API_VERSION,
            "-d", json_body,
            "--max-time", "10",
        },
        on_exit = function(j, return_val)
            vim.schedule(function()
                if return_val ~= 0 then
                    callback(nil, "Request failed")
                    return
                end

                local result = table.concat(j:result(), "\n")
                local ok, decoded = pcall(vim.json.decode, result)

                if not ok then
                    callback(nil, "Failed to decode response")
                    return
                end

                if decoded.error then
                    callback(nil, decoded.error.message or "API error")
                    return
                end

                if decoded.content and #decoded.content > 0 then
                    callback(decoded.content[1].text, nil)
                else
                    callback(nil, "No content in response")
                end
            end)
        end,
    }):start()
end

---Get current model
---@return string
function M.get_model()
    return state.model
end

---Set model
---@param model string
function M.set_model(model)
    -- Allow shortcuts
    if model == "fast" or model == "haiku" then
        state.model = MODELS.fast
    elseif model == "smart" or model == "sonnet" then
        state.model = MODELS.smart
    else
        state.model = model
    end
end

---Get available models
---@return table
function M.get_models()
    return MODELS
end

---Use fast model for simple completions
function M.use_fast()
    state.model = MODELS.fast
end

---Use smart model for complex completions
function M.use_smart()
    state.model = MODELS.smart
end

---Clear API key (for re-authentication)
function M.clear_auth()
    state.api_key = nil
    state.initialized = false
end

---Get status
---@return table
function M.status()
    return {
        initialized = state.initialized,
        model = state.model,
        has_key = state.api_key ~= nil,
    }
end

return M
