-- Plain TypeScript Profile
-- Default conventions for TypeScript projects without a framework
local M = {}

M.id = "plain_typescript"
M.name = "TypeScript"
M.language = "typescript"

-- Default patterns for plain TypeScript
M.conventions = {
    -- Null handling
    null_style = "optional_chaining",  -- optional_chaining, explicit_check

    -- Async style
    async_style = "async_await",  -- async_await, promises

    -- Error handling
    error_style = "throw",  -- throw, return_result

    -- Module style
    module_style = "es6",  -- es6, commonjs
}

-- Template context additions for plain TypeScript
M.context_defaults = {
    -- Type safety
    use_strict_types = true,
    use_interfaces = true,

    -- Standard patterns
    use_arrow_functions = true,
    use_const = true,

    -- Imports
    standard_imports = {},
}

---Apply profile to a template context
---@param context table Template context
---@return table Modified context
function M.apply(context)
    for k, v in pairs(M.context_defaults) do
        if context[k] == nil then
            context[k] = v
        end
    end

    context.framework = M.id
    context.framework_name = M.name

    return context
end

---Modify generated code for TypeScript
---@param code string Generated code
---@return string Modified code
function M.post_process(code)
    return code
end

return M
