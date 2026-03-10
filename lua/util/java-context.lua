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

--- Find project root by looking for build files
---@return string|nil
function M.find_project_root()
    local markers = { "pom.xml", "build.gradle", "build.gradle.kts" }
    local current = vim.fn.expand("%:p:h")

    -- If buffer has no path, use cwd
    if current == "" then
        current = vim.fn.getcwd()
    end

    while current ~= "/" and current ~= "" do
        for _, marker in ipairs(markers) do
            local marker_path = current .. "/" .. marker
            if vim.fn.filereadable(marker_path) == 1 then
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

    local lines = vim.fn.readfile(pom_path)
    local content = table.concat(lines, "\n")

    -- Remove parent section to avoid getting parent's groupId
    local without_parent = content:gsub("<parent>.-</parent>", "")

    -- Get groupId from project level
    local group_id = without_parent:match("<groupId>%s*([^%s<]+)%s*</groupId>")

    -- If not found, try the original content (might be inheriting from parent)
    if not group_id then
        group_id = content:match("<groupId>%s*([^%s<]+)%s*</groupId>")
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

    local lines = vim.fn.readfile(gradle_path)
    local content = table.concat(lines, "\n")

    -- Match group = "com.example" or group = 'com.example' or group("com.example")
    local group = content:match('group%s*=%s*"([^"]+)"')
        or content:match("group%s*=%s*'([^']+)'")
        or content:match('group%s*%(%s*"([^"]+)"')
        or content:match("group%s*%(%s*'([^']+)'")

    return group
end

--- Get package name from current file path
--- Looks for src/main/java or src/test/java patterns
---@return string|nil
function M.get_package_from_path()
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then
        return nil
    end

    -- Match standard Maven/Gradle structure: src/main/java/com/example/app/Controller.java
    local package = filepath:match("src/main/java/(.+)/[^/]+%.java$")
        or filepath:match("src/test/java/(.+)/[^/]+%.java$")

    if package then
        -- Convert path to package name
        local pkg = package:gsub("/", ".")
        -- Validate it looks like a real package (starts with common patterns)
        if pkg:match("^[a-z]+%.[a-z]+") then
            return pkg
        end
    end

    return nil
end

--- Get package name from current buffer's package declaration
---@return string|nil
function M.get_package_from_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 15, false)
    for _, line in ipairs(lines) do
        local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
        if pkg then
            return pkg
        end
    end
    return nil
end

--- Get the base package for the current project
--- Priority: pom.xml/build.gradle > existing package declaration > path > fallback
---@return string
function M.get_base_package()
    -- First, try to get from project build files (most reliable)
    local root = M.find_project_root()
    if root then
        -- Check cache first
        if project_cache[root] then
            return project_cache[root]
        end

        local pkg = M.get_package_from_pom(root) or M.get_package_from_gradle(root)
        if pkg and pkg:match("^[a-z]+%.[a-z]+") then
            project_cache[root] = pkg
            return pkg
        end
    end

    -- Try from current buffer's package declaration
    local pkg = M.get_package_from_buffer()
    if pkg then
        -- Return base package (first 2-3 segments)
        local parts = {}
        for part in pkg:gmatch("[^%.]+") do
            table.insert(parts, part)
            if #parts >= 3 then break end
        end
        if #parts >= 2 then
            return table.concat(parts, ".")
        end
    end

    -- Try from file path
    pkg = M.get_package_from_path()
    if pkg then
        local parts = {}
        for part in pkg:gmatch("[^%.]+") do
            table.insert(parts, part)
            if #parts >= 3 then break end
        end
        if #parts >= 2 then
            return table.concat(parts, ".")
        end
    end

    return "com.example"
end

--- Get full package name for current file location
---@return string
function M.get_package()
    -- First try from buffer
    local pkg = M.get_package_from_buffer()
    if pkg then
        return pkg
    end

    -- Then try from path
    pkg = M.get_package_from_path()
    if pkg then
        return pkg
    end

    -- Fallback to base package
    return M.get_base_package()
end

--- Clear project cache (useful when switching projects)
function M.clear_cache()
    project_cache = {}
end

--- Debug function to check detection
function M.debug()
    local root = M.find_project_root()
    print("Project root: " .. (root or "not found"))
    if root then
        print("From pom.xml: " .. (M.get_package_from_pom(root) or "not found"))
        print("From gradle: " .. (M.get_package_from_gradle(root) or "not found"))
    end
    print("From buffer: " .. (M.get_package_from_buffer() or "not found"))
    print("From path: " .. (M.get_package_from_path() or "not found"))
    print("Base package: " .. M.get_base_package())
    print("Full package: " .. M.get_package())
end

return M
