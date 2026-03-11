-- Framework Module
-- Coordinates framework detection and profile application
local M = {}

local detector = require("suggestion.framework.detector")

-- Profile cache per project
local profile_cache = {}

-- Available profiles
local profiles = {
    plain_java = "suggestion.framework.profiles.java",
    spring_boot = "suggestion.framework.profiles.spring_boot",
    spring_webflux = "suggestion.framework.profiles.spring_boot",  -- Use same as spring_boot
    quarkus = "suggestion.framework.profiles.java",  -- Fallback to plain java
    micronaut = "suggestion.framework.profiles.java",  -- Fallback to plain java
    jakarta_ee = "suggestion.framework.profiles.java",  -- Fallback to plain java
    plain_typescript = "suggestion.framework.profiles.typescript",
    plain_javascript = "suggestion.framework.profiles.typescript",  -- Use TS profile
    react = "suggestion.framework.profiles.react",
    nextjs = "suggestion.framework.profiles.react",  -- Use React profile
    angular = "suggestion.framework.profiles.typescript",  -- Fallback to TS
    vue = "suggestion.framework.profiles.typescript",  -- Fallback to TS
    express = "suggestion.framework.profiles.typescript",  -- Fallback to TS
    nestjs = "suggestion.framework.profiles.typescript",  -- Fallback to TS
}

---Get framework info for current project
---@param project_root string|nil Project root (nil = detect from cwd)
---@return FrameworkInfo|nil
function M.detect(project_root)
    project_root = project_root or vim.fn.getcwd()
    return detector.detect(project_root)
end

---Get framework for current buffer's filetype
---@param bufnr number|nil Buffer number
---@return FrameworkInfo|nil
function M.detect_for_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    local project_root = vim.fn.getcwd()

    return detector.detect_for_filetype(ft, project_root)
end

---Load profile for a framework
---@param framework_id string Framework ID
---@return table|nil Profile module
local function load_profile(framework_id)
    local profile_module = profiles[framework_id]
    if not profile_module then
        return nil
    end

    local ok, profile = pcall(require, profile_module)
    if ok then
        return profile
    end

    return nil
end

---Get profile for current project
---@param project_root string|nil Project root
---@return table|nil Profile module
function M.get_profile(project_root)
    project_root = project_root or vim.fn.getcwd()

    -- Check cache
    if profile_cache[project_root] then
        return profile_cache[project_root]
    end

    -- Detect framework
    local framework = M.detect(project_root)
    if not framework then
        return nil
    end

    -- Load profile
    local profile = load_profile(framework.id)
    if profile then
        profile_cache[project_root] = profile
    end

    return profile
end

---Get profile for current buffer
---@param bufnr number|nil Buffer number
---@return table|nil Profile module
function M.get_profile_for_buffer(bufnr)
    local framework = M.detect_for_buffer(bufnr)
    if not framework then
        return nil
    end

    return load_profile(framework.id)
end

---Apply framework profile to a template context
---@param context table Template context
---@param bufnr number|nil Buffer number
---@return table Modified context
function M.apply_profile(context, bufnr)
    local profile = M.get_profile_for_buffer(bufnr)
    if profile and profile.apply then
        return profile.apply(context)
    end
    return context
end

---Post-process generated code with framework conventions
---@param code string Generated code
---@param bufnr number|nil Buffer number
---@return string Modified code
function M.post_process(code, bufnr)
    local profile = M.get_profile_for_buffer(bufnr)
    if profile and profile.post_process then
        return profile.post_process(code)
    end
    return code
end

---Clear profile cache
---@param project_root string|nil Project root (nil = all)
function M.clear_cache(project_root)
    if project_root then
        profile_cache[project_root] = nil
    else
        profile_cache = {}
    end
end

---Check if a framework is detected
---@param framework_id string Framework ID to check
---@param project_root string|nil Project root
---@return boolean
function M.is_framework(framework_id, project_root)
    local framework = M.detect(project_root)
    return framework and framework.id == framework_id
end

return M
