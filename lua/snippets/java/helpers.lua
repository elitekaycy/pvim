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

return M
