-- FreeMarker Template Language snippets
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- Use square brackets as delimiters to avoid conflict with FreeMarker ${} and <#> syntax
local function f(str, nodes)
    return fmt(str, nodes, { delimiters = "[]" })
end

return {
    -- Interpolation
    s("$", f("${[]}", { i(1, "variable") })),

    -- If directive
    s("if", f([[
<#if []>
    []
</#if>
]], { i(1, "condition"), i(2) })),

    -- If-else
    s("ife", f([[
<#if []>
    []
<#else>
    []
</#if>
]], { i(1, "condition"), i(2), i(3) })),

    -- If-elseif-else
    s("ifeif", f([[
<#if []>
    []
<#elseif []>
    []
<#else>
    []
</#if>
]], { i(1, "condition1"), i(2), i(3, "condition2"), i(4), i(5) })),

    -- List/foreach
    s("list", f([[
<#list [] as []>
    []
</#list>
]], { i(1, "items"), i(2, "item"), i(3) })),

    -- List with index
    s("listi", f([[
<#list [] as []>
    ${[]?index}: []
</#list>
]], { i(1, "items"), i(2, "item"), i(3, "item"), i(4) })),

    -- List with sep
    s("lists", f([[
<#list [] as []>
    []
    <#sep>, </#sep>
</#list>
]], { i(1, "items"), i(2, "item"), i(3, "${item}") })),

    -- List with items/else
    s("liste", f([[
<#list [] as []>
    <#items as []>
        []
    </#items>
<#else>
    []
</#list>
]], { i(1, "items"), i(2, "item"), i(3, "item"), i(4), i(5, "No items") })),

    -- Switch/case
    s("switch", f([[
<#switch []>
    <#case []>
        []
        <#break>
    <#case []>
        []
        <#break>
    <#default>
        []
</#switch>
]], { i(1, "variable"), i(2, "value1"), i(3), i(4, "value2"), i(5), i(6) })),

    -- Macro definition
    s("macro", f([[
<#macro [] []>
    []
</#macro>
]], { i(1, "name"), i(2, "params"), i(3) })),

    -- Macro call
    s("@", f("<@[] []/>", { i(1, "macroName"), i(2) })),

    -- Macro call with body
    s("@@", f([[
<@[] []>
    []
</@[]>
]], { i(1, "macroName"), i(2), i(3), i(4, "macroName") })),

    -- Function
    s("func", f([[
<#function [] []>
    <#return []>
</#function>
]], { i(1, "name"), i(2, "params"), i(3) })),

    -- Assign
    s("assign", f("<#assign [] = []/>", { i(1, "var"), i(2, "value") })),

    -- Assign block
    s("assignb", f([[
<#assign []>
    []
</#assign>
]], { i(1, "var"), i(2) })),

    -- Local variable
    s("local", f("<#local [] = []/>", { i(1, "var"), i(2, "value") })),

    -- Global variable
    s("global", f("<#global [] = []/>", { i(1, "var"), i(2, "value") })),

    -- Include
    s("include", f([[<#include "[]"[]/>]], { i(1, "template.ftl"), i(2) })),

    -- Import
    s("import", f([[<#import "[]" as []/>]], { i(1, "template.ftl"), i(2, "ns") })),

    -- Comment
    s("comment", f("<#-- [] -->", { i(1, "comment") })),

    -- Attempt/recover (try-catch equivalent)
    s("attempt", f([[
<#attempt>
    []
<#recover>
    []
</#attempt>
]], { i(1), i(2, "Error occurred") })),

    -- Compress (remove whitespace)
    s("compress", f([[
<#compress>
    []
</#compress>
]], { i(1) })),

    -- Escape HTML
    s("escape", f([[
<#escape x as x?html>
    []
</#escape>
]], { i(1) })),

    -- Noparse (output FreeMarker syntax literally)
    s("noparse", f([[
<#noparse>
    []
</#noparse>
]], { i(1) })),

    -- Default value
    s("default", f("${[]![]}", { i(1, "variable"), i(2, "default") })),

    -- Default empty string
    s("default!", f("${[]!}", { i(1, "variable") })),

    -- Null check
    s("has", f([[
<#if []??>
    []
</#if>
]], { i(1, "variable"), i(2) })),

    -- Has content check
    s("hasc", f([[
<#if []?has_content>
    []
</#if>
]], { i(1, "variable"), i(2) })),

    -- Built-in string operations
    s("upper", f("${[]?upper_case}", { i(1, "string") })),
    s("lower", f("${[]?lower_case}", { i(1, "string") })),
    s("cap", f("${[]?cap_first}", { i(1, "string") })),
    s("trim", f("${[]?trim}", { i(1, "string") })),

    -- Built-in date/number formatting
    s("date", f("${[]?date}", { i(1, "date") })),
    s("datetime", f("${[]?datetime}", { i(1, "datetime") })),
    s("number", f("${[]?string('[]')}", { i(1, "number"), i(2, "0.00") })),

    -- Size/length
    s("size", f("${[]?size}", { i(1, "collection") })),

    -- FTL page template
    s("ftlpage", f([[
<#-- [] -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${[]}</title>
</head>
<body>
    []
</body>
</html>
]], { i(1, "Template description"), i(2, "title"), i(3) })),

    -- FTL with Spring
    s("ftlspring", f([[
<#import "/spring.ftl" as spring/>

<@spring.bind "[]"/>
[]
]], { i(1, "path"), i(2) })),
}
