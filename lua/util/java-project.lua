-- Java project structure analyzer
local M = {}

local ctx = require("util.java-context")

---@class ProjectStructure
---@field root string Project root path
---@field base_package string Base package (e.g., com.example.app)
---@field src_main string Path to src/main/java
---@field src_test string Path to src/test/java
---@field packages table<string, string> Map of package type to full path

--- Find all existing package directories in the project
---@param root string
---@param base_pkg string
---@return table<string, string>
function M.find_packages(root, base_pkg)
    local src_main = root .. "/src/main/java"
    local base_path = src_main .. "/" .. base_pkg:gsub("%.", "/")

    local packages = {
        entity = nil,
        dto = nil,
        repository = nil,
        mapper = nil,
        service = nil,
        controller = nil,
        config = nil,
        exception = nil,
    }

    -- Check which packages exist
    for pkg_type, _ in pairs(packages) do
        local pkg_path = base_path .. "/" .. pkg_type
        if vim.fn.isdirectory(pkg_path) == 1 then
            packages[pkg_type] = pkg_path
        end
    end

    return packages
end

--- Get full project structure
---@return ProjectStructure|nil
function M.get_structure()
    local root = ctx.find_project_root()
    if not root then
        return nil
    end

    local base_pkg = ctx.get_base_package()
    local src_main = root .. "/src/main/java"
    local src_test = root .. "/src/test/java"

    return {
        root = root,
        base_package = base_pkg,
        src_main = src_main,
        src_test = src_test,
        packages = M.find_packages(root, base_pkg),
    }
end

--- Get the path for a package type, creating structure info
---@param pkg_type string e.g., "entity", "controller"
---@return string|nil path, string|nil package_name
function M.get_package_path(pkg_type)
    local structure = M.get_structure()
    if not structure then
        return nil, nil
    end

    local base_path = structure.src_main .. "/" .. structure.base_package:gsub("%.", "/")
    local pkg_path = base_path .. "/" .. pkg_type
    local pkg_name = structure.base_package .. "." .. pkg_type

    return pkg_path, pkg_name
end

--- Get test path for a package type
---@param pkg_type string
---@return string|nil path, string|nil package_name
function M.get_test_path(pkg_type)
    local structure = M.get_structure()
    if not structure then
        return nil, nil
    end

    local base_path = structure.src_test .. "/" .. structure.base_package:gsub("%.", "/")
    local pkg_path = base_path .. "/" .. pkg_type
    local pkg_name = structure.base_package .. "." .. pkg_type

    return pkg_path, pkg_name
end

--- Create directory if it doesn't exist
---@param path string
---@return boolean
function M.ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
        return true
    end
    return false
end

--- List existing entities in the project
---@return string[]
function M.list_entities()
    local path = M.get_package_path("entity")
    if not path or vim.fn.isdirectory(path) == 0 then
        return {}
    end

    local entities = {}
    local files = vim.fn.glob(path .. "/*.java", false, true)
    for _, file in ipairs(files) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        -- Skip base classes
        if not name:match("^Base") and not name:match("^Abstract") then
            table.insert(entities, name)
        end
    end
    return entities
end

--- Check what files exist for an entity
---@param entity_name string
---@return table<string, boolean>
function M.check_entity_files(entity_name)
    local structure = M.get_structure()
    if not structure then
        return {}
    end

    local base_path = structure.src_main .. "/" .. structure.base_package:gsub("%.", "/")

    return {
        entity = vim.fn.filereadable(base_path .. "/entity/" .. entity_name .. ".java") == 1,
        dto = vim.fn.filereadable(base_path .. "/dto/" .. entity_name .. "Dto.java") == 1,
        repository = vim.fn.filereadable(base_path .. "/repository/" .. entity_name .. "Repository.java") == 1,
        mapper = vim.fn.filereadable(base_path .. "/mapper/" .. entity_name .. "Mapper.java") == 1,
        service = vim.fn.filereadable(base_path .. "/service/" .. entity_name .. "Service.java") == 1,
        service_impl = vim.fn.filereadable(base_path .. "/service/impl/" .. entity_name .. "ServiceImpl.java") == 1,
        controller = vim.fn.filereadable(base_path .. "/controller/" .. entity_name .. "Controller.java") == 1,
    }
end

--- Debug: print project structure
function M.debug()
    local structure = M.get_structure()
    if not structure then
        print("No project structure found")
        return
    end

    print("Project root: " .. structure.root)
    print("Base package: " .. structure.base_package)
    print("src/main/java: " .. structure.src_main)
    print("src/test/java: " .. structure.src_test)
    print("\nExisting packages:")
    for pkg_type, path in pairs(structure.packages) do
        if path then
            print("  " .. pkg_type .. ": " .. path)
        end
    end
    print("\nExisting entities:")
    for _, entity in ipairs(M.list_entities()) do
        print("  " .. entity)
    end
end

return M
