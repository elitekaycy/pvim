-- AI Context Builder
-- Builds MINIMAL context for Claude prompts - optimized for token efficiency
local M = {}

---@class AIContext
---@field file_context table Current file analysis
---@field framework table|nil Detected framework
---@field method_info table Method being completed
---@field compact boolean Use compact format

---Build minimal context for code suggestion
---@param method_name string Method name
---@param return_type string|nil Return type
---@param params string|nil Parameters
---@param bufnr number|nil Buffer number
---@return AIContext
function M.build(method_name, return_type, params, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local context = {
        file_context = nil,
        framework = nil,
        method_info = {
            name = method_name,
            return_type = return_type,
            params = params,
        },
        compact = true,
    }

    -- Get file context (minimal)
    local context_ok, file_context_module = pcall(require, "suggestion.context")
    if context_ok then
        local full_ctx = file_context_module.get(bufnr)
        if full_ctx then
            -- Only keep essential fields
            context.file_context = {
                class_name = full_ctx.class_name,
                class_type = full_ctx.class_type,
                fields = {},
                methods = {},
            }
            -- Only injected fields (dependencies)
            if full_ctx.fields then
                for _, f in ipairs(full_ctx.fields) do
                    if f.injected then
                        table.insert(context.file_context.fields, { n = f.name, t = f.type })
                    end
                end
            end
            -- Only method names (max 5)
            if full_ctx.methods then
                for i, m in ipairs(full_ctx.methods) do
                    if i > 5 then break end
                    table.insert(context.file_context.methods, m)
                end
            end
        end
    end

    -- Get framework (just the ID)
    local framework_ok, framework_module = pcall(require, "suggestion.framework")
    if framework_ok then
        local fw = framework_module.detect_for_buffer(bufnr)
        if fw then
            context.framework = { id = fw.id }
        end
    end

    return context
end

---Format context as MINIMAL prompt string
---@param context AIContext
---@return string
function M.format_prompt(context)
    local parts = {}

    -- Ultra-compact format
    -- Class:Type|field1:Type1,field2:Type2|method1,method2
    if context.file_context then
        local fc = context.file_context
        local line = (fc.class_name or "?") .. ":" .. (fc.class_type or "class")

        if fc.fields and #fc.fields > 0 then
            local fields = {}
            for _, f in ipairs(fc.fields) do
                table.insert(fields, f.n .. ":" .. (f.t or "?"))
            end
            line = line .. "|" .. table.concat(fields, ",")
        end

        if fc.methods and #fc.methods > 0 then
            line = line .. "|" .. table.concat(fc.methods, ",")
        end

        table.insert(parts, line)
    end

    -- Framework (single word)
    if context.framework then
        table.insert(parts, "fw:" .. context.framework.id)
    end

    -- Method signature or line context (compact)
    local sig = context.method_info.name
    if context.method_info.params then
        -- If params looks like typed code, use it as context
        if context.method_info.params:match("[%.%(%)]") or #context.method_info.params > 20 then
            table.insert(parts, "code:" .. context.method_info.params)
            table.insert(parts, ">complete")
        else
            sig = sig .. "(" .. context.method_info.params .. ")"
            if context.method_info.return_type then
                sig = context.method_info.return_type .. " " .. sig
            end
            table.insert(parts, ">" .. sig)
        end
    else
        if context.method_info.return_type then
            sig = context.method_info.return_type .. " " .. sig
        end
        table.insert(parts, ">" .. sig)
    end

    return table.concat(parts, "\n")
end

---Build a MINIMAL system prompt for code generation
---@param context AIContext
---@return string
function M.build_system_prompt(context)
    -- Ultra-short system prompt
    local lang = "Java"
    local ft = vim.bo.filetype
    if ft == "typescript" or ft == "typescriptreact" then
        lang = "TS"
    elseif ft == "javascript" or ft == "javascriptreact" then
        lang = "JS"
    end

    local fw = ""
    if context.framework and context.framework.id then
        fw = " " .. context.framework.id
    end

    -- Check if this is line completion vs method body
    local is_line_completion = context.method_info.name == "complete"
        or context.method_info.name:match("^assign")
        or context.method_info.name:match("^return")
        or context.method_info.name:match("^call")

    if is_line_completion then
        return lang .. fw .. " complete this line. Output ONLY the completion (no explanation). Short, 1 line preferred."
    else
        return lang .. fw .. " method body only. No markdown. Use available fields."
    end
end

return M
