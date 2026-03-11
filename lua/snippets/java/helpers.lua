-- Shared helpers for Java snippets
local M = {}

local ls = require("luasnip")
local java_ctx = require("util.java-context")

M.s = ls.snippet
M.t = ls.text_node
M.i = ls.insert_node
M.f = ls.function_node
M.c = ls.choice_node
M.d = ls.dynamic_node
M.fmt = require("luasnip.extras.fmt").fmt
M.rep = require("luasnip.extras").rep

-- Context functions
function M.pkg() return java_ctx.get_package() end
function M.base_pkg() return java_ctx.get_base_package() end
function M.class_name() return java_ctx.get_class_name() end

function M.lowercase_first(str)
    if not str or str == "" then return str end
    return str:sub(1,1):lower() .. str:sub(2)
end

function M.uppercase_first(str)
    if not str or str == "" then return str end
    return str:sub(1,1):upper() .. str:sub(2)
end

-- Extract entity name from class name
-- UserController -> User
-- UserService -> User
-- UserServiceImpl -> User
-- UserRepository -> User
-- UserDto / UserDTO -> User
-- UserMapper -> User
-- UserTest -> User
-- User -> User
function M.entity_name()
    local class = java_ctx.get_class_name()
    if not class or class == "" then
        return "Entity"
    end

    -- Remove common suffixes
    local suffixes = {
        "Controller", "RestController",
        "ServiceImpl", "Service",
        "RepositoryImpl", "Repository",
        "MapperImpl", "Mapper",
        "DTO", "Dto", "Request", "Response",
        "Test", "Tests", "IT",
        "Config", "Configuration",
        "Exception", "Handler",
    }

    for _, suffix in ipairs(suffixes) do
        if class:sub(-#suffix) == suffix and #class > #suffix then
            return class:sub(1, -#suffix - 1)
        end
    end

    return class
end

-- Get entity name as variable (lowercase first letter)
-- UserController -> user
function M.entity_var()
    return M.lowercase_first(M.entity_name())
end

-- Get table name from entity (lowercase, plural)
-- User -> users
function M.table_name()
    local entity = M.entity_name():lower()
    -- Simple pluralization
    if entity:sub(-1) == "s" or entity:sub(-1) == "x" or entity:sub(-2) == "ch" or entity:sub(-2) == "sh" then
        return entity .. "es"
    elseif entity:sub(-1) == "y" and not entity:sub(-2, -2):match("[aeiou]") then
        return entity:sub(1, -2) .. "ies"
    else
        return entity .. "s"
    end
end

-- Get endpoint path from entity
-- User -> users
function M.endpoint()
    return M.table_name()
end

return M
