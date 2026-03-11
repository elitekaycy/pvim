-- Plain Java Profile
-- Default conventions for Java projects without a framework
local M = {}

M.id = "plain_java"
M.name = "Java"
M.language = "java"

-- Default patterns for plain Java
M.conventions = {
    -- Exception handling
    exception_not_found = "IllegalArgumentException",
    exception_validation = "IllegalArgumentException",

    -- Optional handling
    optional_style = "orElse",  -- orElse, orElseThrow, get

    -- Collection style
    stream_collect = "toList",  -- toList (Java 16+), Collectors.toList()

    -- Logging (assume no logging framework by default)
    logging = false,
}

-- Template context additions for plain Java
M.context_defaults = {
    -- No DI annotations
    use_constructor_injection = true,
    use_field_annotations = false,

    -- Standard imports
    standard_imports = {
        "java.util.List",
        "java.util.Optional",
        "java.util.ArrayList",
        "java.util.Map",
        "java.util.HashMap",
    },
}

-- Template modifications for plain Java
M.template_modifiers = {
    -- Remove @Service, @Repository annotations
    remove_patterns = {
        "@Service%s*\n",
        "@Repository%s*\n",
        "@Component%s*\n",
        "@Autowired%s*\n",
        "@Transactional.-\n",
        "lombok%.RequiredArgsConstructor",
    },

    -- Add constructor if fields present
    add_constructor = true,
}

---Apply profile to a template context
---@param context table Template context
---@return table Modified context
function M.apply(context)
    -- Merge defaults
    for k, v in pairs(M.context_defaults) do
        if context[k] == nil then
            context[k] = v
        end
    end

    context.framework = M.id
    context.framework_name = M.name

    return context
end

---Modify generated code for plain Java
---@param code string Generated code
---@return string Modified code
function M.post_process(code)
    -- Remove framework-specific annotations
    for _, pattern in ipairs(M.template_modifiers.remove_patterns) do
        code = code:gsub(pattern, "")
    end

    return code
end

return M
