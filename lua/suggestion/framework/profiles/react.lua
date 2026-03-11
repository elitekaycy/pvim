-- React Profile
-- Conventions and enhancements for React projects
local M = {}

M.id = "react"
M.name = "React"
M.language = "typescript"

-- React conventions
M.conventions = {
    -- Component style
    component_style = "functional",  -- functional, class

    -- State management
    state_style = "hooks",  -- hooks, class_state, redux

    -- Styling
    styling = "css_modules",  -- css_modules, styled_components, tailwind

    -- Hooks
    use_hooks = true,
    prefer_use_callback = true,
    prefer_use_memo = true,
}

-- Template context additions for React
M.context_defaults = {
    -- Component defaults
    use_functional_components = true,
    use_arrow_functions = true,
    use_typescript = true,

    -- Hooks
    common_hooks = {
        "useState",
        "useEffect",
        "useCallback",
        "useMemo",
        "useRef",
    },

    -- Imports
    standard_imports = {
        "react",
    },
}

-- Template enhancements for React
M.template_enhancements = {
    -- Add memo for performance
    wrap_with_memo = false,

    -- Use proper event types
    use_typed_events = true,
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

    -- Add React-specific context
    if context.class_type == "component" or context.class_type == "react_component" then
        context.is_component = true
        context.use_props_interface = true
    elseif context.class_type == "hook" then
        context.is_hook = true
        context.hook_prefix = "use"
    end

    return context
end

---Modify generated code for React
---@param code string Generated code
---@return string Modified code
function M.post_process(code)
    return code
end

---Get hook pattern
---@param hook_name string Hook name (without 'use' prefix)
---@return string Hook usage pattern
function M.get_hook_pattern(hook_name)
    local patterns = {
        State = "const [${var}, set${Var}] = useState<${type}>(${default});",
        Effect = "useEffect(() => {\n    ${body}\n}, [${deps}]);",
        Callback = "const ${name} = useCallback((${params}) => {\n    ${body}\n}, [${deps}]);",
        Memo = "const ${name} = useMemo(() => ${expression}, [${deps}]);",
        Ref = "const ${name}Ref = useRef<${type}>(${default});",
    }
    return patterns[hook_name] or ""
end

---Get component scaffold
---@param name string Component name
---@param with_props boolean Include props interface
---@return string Component scaffold
function M.get_component_scaffold(name, with_props)
    if with_props then
        return string.format([[
interface %sProps {
    // TODO: Add props
}

export const %s: React.FC<%sProps> = ({ }) => {
    return (
        <div>
            {/* TODO: Add content */}
        </div>
    );
};
]], name, name, name)
    else
        return string.format([[
export const %s: React.FC = () => {
    return (
        <div>
            {/* TODO: Add content */}
        </div>
    );
};
]], name)
    end
end

return M
