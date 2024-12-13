local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt


return {
    s("ctor", fmt(
        "public {}({}) {{\n{}\n}}",
        {
            f(function(args)
                return args[1][1] or "ClassName"
            end, { 1 }),
            i(1, "parameters"),
            i(2, "// Constructor body")
        }
    )),

    s("log", fmt(
        "System.out.println({});",
        {
            i(1, "message")
        }
    )),
}
