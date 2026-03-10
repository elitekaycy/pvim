-- Java context detection for dynamic snippets
local M = {}

-- Cache for project info to avoid repeated file reads
local project_cache = {}

--- Get class name from current buffer filename
---@return string
function M.get_class_name()
    local filename = vim.fn.expand("%:t:r")
    if filename == "" then
        return "MyClass"
    end
    return filename
end

--- Get package name from current file path
--- Looks for src/main/java or src/test/java patterns
---@return string
function M.get_package_from_path()
    local filepath = vim.fn.expand("%:p")

    -- Match standard Maven/Gradle structure
    local package = filepath:match("src/main/java/(.+)/[^/]+%.java$")
        or filepath:match("src/test/java/(.+)/[^/]+%.java$")
        or filepath:match("src/(.+)/[^/]+%.java$")

    if package then
        return package:gsub("/", ".")
    end

    return nil
end

--- Get package name from current buffer's package declaration
---@return string|nil
function M.get_package_from_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
    for _, line in ipairs(lines) do
        local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
        if pkg then
            return pkg
        end
    end
    return nil
end

--- Find project root by looking for build files
---@return string|nil
function M.find_project_root()
    local markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", ".git" }
    local current = vim.fn.expand("%:p:h")

    while current ~= "/" do
        for _, marker in ipairs(markers) do
            if vim.fn.filereadable(current .. "/" .. marker) == 1
                or vim.fn.isdirectory(current .. "/" .. marker) == 1 then
                return current
            end
        end
        current = vim.fn.fnamemodify(current, ":h")
    end

    return nil
end

--- Extract base package from pom.xml
---@param root string
---@return string|nil
function M.get_package_from_pom(root)
    local pom_path = root .. "/pom.xml"
    if vim.fn.filereadable(pom_path) == 0 then
        return nil
    end

    local content = table.concat(vim.fn.readfile(pom_path), "\n")

    -- Try to get groupId (skip parent groupId)
    -- Look for groupId that's a direct child of project, not parent
    local group_id = content:match("<project[^>]*>.-<groupId>([^<]+)</groupId>")

    -- If not found at project level, try after </parent>
    if not group_id then
        group_id = content:match("</parent>.-<groupId>([^<]+)</groupId>")
    end

    -- Fallback: just get any groupId
    if not group_id then
        group_id = content:match("<groupId>([^<]+)</groupId>")
    end

    return group_id
end

--- Extract base package from build.gradle
---@param root string
---@return string|nil
function M.get_package_from_gradle(root)
    local gradle_path = root .. "/build.gradle"
    if vim.fn.filereadable(gradle_path) == 0 then
        gradle_path = root .. "/build.gradle.kts"
    end
    if vim.fn.filereadable(gradle_path) == 0 then
        return nil
    end

    local content = table.concat(vim.fn.readfile(gradle_path), "\n")

    -- Match group = "com.example" or group = 'com.example'
    local group = content:match('group%s*=%s*["\']([^"\']+)["\']')
        or content:match('group%s*["\']([^"\']+)["\']')

    return group
end

--- Get the base package for the current project
--- Tries multiple sources: buffer, path, pom.xml, build.gradle
---@return string
function M.get_base_package()
    -- First try from current buffer
    local pkg = M.get_package_from_buffer()
    if pkg then
        -- Return base package (first 2-3 segments usually)
        local parts = {}
        for part in pkg:gmatch("[^%.]+") do
            table.insert(parts, part)
            if #parts >= 3 then break end
        end
        return table.concat(parts, ".")
    end

    -- Try from file path
    pkg = M.get_package_from_path()
    if pkg then
        local parts = {}
        for part in pkg:gmatch("[^%.]+") do
            table.insert(parts, part)
            if #parts >= 3 then break end
        end
        return table.concat(parts, ".")
    end

    -- Try from project build files
    local root = M.find_project_root()
    if root then
        -- Check cache first
        if project_cache[root] then
            return project_cache[root]
        end

        pkg = M.get_package_from_pom(root) or M.get_package_from_gradle(root)
        if pkg then
            project_cache[root] = pkg
            return pkg
        end
    end

    return "com.example"
end

--- Get full package name for current file location
---@return string
function M.get_package()
    local pkg = M.get_package_from_buffer()
    if pkg then
        return pkg
    end

    pkg = M.get_package_from_path()
    if pkg then
        return pkg
    end

    return M.get_base_package()
end

--- Get the entity/model package based on current project
---@return string
function M.get_entity_package()
    return M.get_base_package() .. ".entity"
end

--- Get the dto package based on current project
---@return string
function M.get_dto_package()
    return M.get_base_package() .. ".dto"
end

--- Get the service package based on current project
---@return string
function M.get_service_package()
    return M.get_base_package() .. ".service"
end

--- Get the repository package based on current project
---@return string
function M.get_repository_package()
    return M.get_base_package() .. ".repository"
end

--- Get the controller package based on current project
---@return string
function M.get_controller_package()
    return M.get_base_package() .. ".controller"
end

--- Get the config package based on current project
---@return string
function M.get_config_package()
    return M.get_base_package() .. ".config"
end

--- Get the exception package based on current project
---@return string
function M.get_exception_package()
    return M.get_base_package() .. ".exception"
end

--- Clear project cache (useful when switching projects)
function M.clear_cache()
    project_cache = {}
end

return M
