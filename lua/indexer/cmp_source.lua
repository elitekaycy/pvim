-- nvim-cmp source for code suggestions
-- Uses the new context-aware suggestion system
local source = {}

---Return whether this source is available in the current context
---@return boolean
function source:is_available()
    local ft = vim.bo.filetype
    return ft == "java" or ft == "typescript" or ft == "typescriptreact"
        or ft == "javascript" or ft == "javascriptreact"
end

---Return the debug name of this source
---@return string
function source:get_debug_name()
    return "project_index"
end

---Return trigger characters for this source
---@return string[]
function source:get_trigger_characters()
    return { "(", "{" }
end

---Extract method signature from current line
---@param line string
---@return string|nil method_name
---@return string|nil return_type
local function extract_method_signature(line)
    local return_type, method_name

    -- Java: "public/private/protected returnType methodName("
    _, return_type, method_name = line:match("(public%s+)(%w+)%s+(%w+)%s*%($")
    if method_name then return method_name, return_type end

    _, return_type, method_name = line:match("(private%s+)(%w+)%s+(%w+)%s*%($")
    if method_name then return method_name, return_type end

    _, return_type, method_name = line:match("(protected%s+)(%w+)%s+(%w+)%s*%($")
    if method_name then return method_name, return_type end

    -- Java: "@Override returnType methodName("
    return_type, method_name = line:match("@Override%s+(%w+)%s+(%w+)%s*%($")
    if method_name then return method_name, return_type end

    -- Java: "returnType methodName("
    return_type, method_name = line:match("(%w+)%s+(%w+)%s*%($")
    if method_name then return method_name, return_type end

    -- TypeScript: "async methodName("
    method_name = line:match("async%s+(%w+)%s*%($")
    if method_name then return method_name, nil end

    -- TypeScript: "function methodName("
    method_name = line:match("function%s+(%w+)%s*%($")
    if method_name then return method_name, nil end

    -- TypeScript: "const methodName = async ("
    method_name = line:match("const%s+(%w+)%s*=%s*async%s*%($")
    if method_name then return method_name, nil end

    -- TypeScript: "const methodName = ("
    method_name = line:match("const%s+(%w+)%s*=%s*%($")
    if method_name then return method_name, nil end

    -- Method in class: "methodName(" at start of line
    method_name = line:match("^%s*(%w+)%s*%($")
    if method_name then return method_name, nil end

    -- TypeScript method with return type: "methodName(): ReturnType {"
    method_name = line:match("(%w+)%s*%(%s*%)%s*:%s*%w")
    if method_name then return method_name, nil end

    return nil, nil
end

---Format score as percentage display
---@param score number
---@return string
local function format_score(score)
    if score >= 80 then
        return string.format("%.0f%%", score)
    elseif score >= 50 then
        return string.format("%.0f%%", score)
    else
        return string.format("%.0f%%", score)
    end
end

---Invoke completion
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
    local line = params.context.cursor_before_line

    local method_name, return_type = extract_method_signature(line)

    if not method_name then
        callback({ items = {}, isIncomplete = false })
        return
    end

    -- Try to use the new suggestion system first
    local ok, suggestion_module = pcall(require, "suggestion")
    local suggestions = {}

    if ok then
        suggestions = suggestion_module.get_suggestions(method_name, return_type, nil)
    else
        -- Fallback to basic indexer
        local indexer_ok, indexer = pcall(require, "indexer")
        if indexer_ok then
            suggestions = indexer.get_suggestions(method_name, return_type, nil)
        end
    end

    if #suggestions == 0 then
        callback({ items = {}, isIncomplete = false })
        return
    end

    local items = {}
    local filetype = vim.bo.filetype

    for idx, suggestion in ipairs(suggestions) do
        local body = suggestion.body

        -- Create a short label
        local label = body:gsub("\n", " "):gsub("%s+", " ")
        if #label > 60 then
            label = label:sub(1, 57) .. "..."
        end

        -- Format detail with score and source
        local detail
        if suggestion.score then
            detail = string.format("[%s %s] %s", suggestion.source, format_score(suggestion.score), method_name)
        else
            detail = string.format("[%s] %s", suggestion.source, method_name)
        end

        -- Build documentation with template info
        local doc_parts = {
            "```" .. filetype,
            body,
            "```",
        }

        if suggestion.template_id then
            table.insert(doc_parts, "")
            table.insert(doc_parts, "**Template:** `" .. suggestion.template_id .. "`")
        end

        if suggestion.scores then
            table.insert(doc_parts, "")
            table.insert(doc_parts, "**Scores:**")
            for signal, score in pairs(suggestion.scores) do
                table.insert(doc_parts, string.format("- %s: %.1f", signal, score))
            end
        end

        table.insert(items, {
            label = label,
            kind = 15, -- Snippet
            detail = detail,
            documentation = {
                kind = "markdown",
                value = table.concat(doc_parts, "\n"),
            },
            insertText = ") {\n    " .. body .. "\n}",
            insertTextFormat = 2, -- Snippet format
            sortText = string.format("%02d", idx),
            data = {
                source = suggestion.source,
                score = suggestion.score,
                template_id = suggestion.template_id,
            },
        })
    end

    callback({ items = items, isIncomplete = false })
end

---Register this source with nvim-cmp
local function register()
    local ok, cmp = pcall(require, "cmp")
    if not ok then
        return
    end

    cmp.register_source("project_index", source)
end

return {
    source = source,
    register = register,
}
