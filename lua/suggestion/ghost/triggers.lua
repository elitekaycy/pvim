-- Ghost Text Triggers
-- Detects when to show suggestions based on cursor context
local M = {}

-- Buffer-local cache for expensive operations
local buffer_cache = {}

-- Clear cache for a buffer
local function clear_buffer_cache(bufnr)
    buffer_cache[bufnr] = nil
end

-- Get or create buffer cache
local function get_buffer_cache(bufnr)
    if not buffer_cache[bufnr] then
        buffer_cache[bufnr] = {
            class_info = nil,
            class_info_line_count = 0,  -- Invalidate if line count changes significantly
        }
    end
    return buffer_cache[bufnr]
end

---@class TriggerResult
---@field type string Trigger type (method_body, statement, expression, class_scaffold)
---@field method_name string|nil Method name if detected
---@field return_type string|nil Return type if detected
---@field context table Additional context

---Check if cursor is after method signature opening brace
---@param line string Current line
---@param col number Cursor column
---@return TriggerResult|nil
local function check_method_body_trigger(line, col)
    -- Pattern: modifiers? returnType methodName(params) {
    local patterns = {
        -- Java: public void methodName() {
        "^%s*(%w+%s+)*(%w+)%s+(%w+)%s*%(.-%)%s*{%s*$",
        -- Java: @Override public void methodName() {
        "^%s*@%w+.-(%w+)%s+(%w+)%s*%(.-%)%s*{%s*$",
        -- TypeScript: methodName(): Type {
        "^%s*(%w+)%s*%(.-%)%s*:%s*(%w+)%s*{%s*$",
        -- TypeScript: async methodName() {
        "^%s*async%s+(%w+)%s*%(.-%)%s*{%s*$",
        -- Arrow function: const name = () => {
        "^%s*const%s+(%w+)%s*=%s*%(.-%)%s*=>%s*{%s*$",
    }

    for _, pattern in ipairs(patterns) do
        local matches = { line:match(pattern) }
        if #matches > 0 then
            -- Extract method name (usually last identifier before parens)
            local method_name = matches[#matches]
            local return_type = #matches > 1 and matches[#matches - 1] or nil

            return {
                type = "method_body",
                method_name = method_name,
                return_type = return_type,
                context = {},
            }
        end
    end

    return nil
end

---Check if cursor is at start of a new statement line
---@param line string Current line
---@param prev_line string|nil Previous line
---@param col number Cursor column
---@return TriggerResult|nil
local function check_statement_trigger(line, prev_line, col)
    -- Only trigger on empty or whitespace-only lines
    if not line:match("^%s*$") then
        return nil
    end

    -- Must have some indentation (inside a block)
    if not line:match("^%s+") then
        return nil
    end

    -- Check previous line for context
    if prev_line then
        -- After variable declaration
        local var_type, var_name = prev_line:match("(%w+)%s+(%w+)%s*[=;]")
        if var_type and var_name then
            return {
                type = "statement",
                context = {
                    prev_var = var_name,
                    prev_type = var_type,
                },
            }
        end

        -- After method call
        local call_result = prev_line:match("(%w+)%s*=%s*%w+%.%w+%(")
        if call_result then
            return {
                type = "statement",
                context = {
                    prev_var = call_result,
                },
            }
        end

        -- After if/for/while opening brace
        if prev_line:match("{%s*$") then
            return {
                type = "statement",
                context = {
                    block_start = true,
                },
            }
        end
    end

    return {
        type = "statement",
        context = {},
    }
end

---Check if cursor is after a dot (method chain)
---@param line string Current line
---@param col number Cursor column
---@return TriggerResult|nil
local function check_expression_trigger(line, col)
    -- Get text before cursor
    local before_cursor = line:sub(1, col)

    -- Check for dot at cursor position
    if before_cursor:match("%.$") then
        -- Extract variable name before dot
        local var_name = before_cursor:match("(%w+)%.$")
        if var_name then
            return {
                type = "expression",
                context = {
                    variable = var_name,
                    chain_position = col,
                },
            }
        end
    end

    return nil
end

---Check if we're typing code (general trigger)
---@param line string Current line
---@param col number Cursor column
---@param bufnr number Buffer number
---@return TriggerResult|nil
local function check_typing_trigger(line, col, bufnr)
    -- Get text before cursor
    local before_cursor = line:sub(1, col)

    -- Skip if line is empty or just whitespace
    if before_cursor:match("^%s*$") then
        return nil
    end

    -- Skip if inside a string or comment
    if before_cursor:match('["\'].-$') or before_cursor:match("//.*$") or before_cursor:match("/%*") then
        return nil
    end

    -- Must have at least 3 chars typed (avoid triggering too early)
    local typed = before_cursor:match("^%s*(.-)%s*$")
    if not typed or #typed < 3 then
        return nil
    end

    -- Detect what kind of completion we need
    local context = {
        text = typed,
        line = line,
    }

    -- Variable assignment: Type var = |
    local var_type, var_name = before_cursor:match("(%w+)%s+(%w+)%s*=%s*$")
    if var_type and var_name then
        return {
            type = "assignment",
            context = {
                var_type = var_type,
                var_name = var_name,
            },
        }
    end

    -- Return statement: return |
    if before_cursor:match("return%s+$") or before_cursor:match("return%s+%w*$") then
        return {
            type = "return",
            context = context,
        }
    end

    -- Method call starting: obj.meth|
    local obj, partial = before_cursor:match("(%w+)%.(%w*)$")
    if obj then
        return {
            type = "method_call",
            context = {
                object = obj,
                partial = partial or "",
            },
        }
    end

    -- Generic line completion
    return {
        type = "line",
        context = context,
    }
end

---Check if we're in an empty class body
---@param bufnr number Buffer number
---@param line_num number Current line number (1-indexed)
---@return TriggerResult|nil
local function check_class_scaffold_trigger(bufnr, line_num)
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Quick check: skip for large files (class scaffold only useful in small/new files)
    if line_count > 20 then
        return nil
    end

    local cache = get_buffer_cache(bufnr)

    -- Check for new file (very few lines, no content) - cheapest check first
    if line_count <= 3 then
        -- Only read the lines we need
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 3, false)
        local total_content = table.concat(lines, "")
        if #total_content < 50 then
            local filename = vim.fn.expand("%:t:r")
            return {
                type = "class_scaffold",
                context = {
                    class_name = filename,
                    new_file = true,
                },
            }
        end
    end

    -- Use cache for class info if line count hasn't changed much
    if cache.class_info and math.abs(cache.class_info_line_count - line_count) < 3 then
        local class_name = cache.class_info.class_name
        if class_name then
            -- Just check if cursor is in the right position
            local before_lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_num, false)
            local before_cursor = table.concat(before_lines, "\n")
            if before_cursor:match("class%s+" .. class_name .. ".-{%s*$") then
                return {
                    type = "class_scaffold",
                    context = {
                        class_name = class_name,
                    },
                }
            end
        end
        return nil
    end

    -- Cache miss - scan file (only for small files due to early exit above)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")

    local class_pattern = "class%s+(%w+).-{%s*}"
    local class_name = content:match(class_pattern)

    -- Update cache
    cache.class_info = { class_name = class_name }
    cache.class_info_line_count = line_count

    if class_name then
        local before_cursor = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, line_num, false), "\n")
        if before_cursor:match("class%s+" .. class_name .. ".-{%s*$") then
            return {
                type = "class_scaffold",
                context = {
                    class_name = class_name,
                },
            }
        end
    end

    return nil
end

---Detect trigger at current cursor position
---@param bufnr number|nil Buffer number
---@return TriggerResult|nil
function M.detect(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor[1]
    local col = cursor[2]

    local lines = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)
    local line = lines[1] or ""

    local prev_line = nil
    if line_num > 1 then
        local prev_lines = vim.api.nvim_buf_get_lines(bufnr, line_num - 2, line_num - 1, false)
        prev_line = prev_lines[1]
    end

    -- Check triggers in priority order

    -- 1. Method body (highest priority - explicit context)
    local method_trigger = check_method_body_trigger(line, col)
    if method_trigger then
        return method_trigger
    end

    -- 2. Expression (dot completion)
    local expr_trigger = check_expression_trigger(line, col)
    if expr_trigger then
        return expr_trigger
    end

    -- 3. Class scaffold (empty class or new file)
    local scaffold_trigger = check_class_scaffold_trigger(bufnr, line_num)
    if scaffold_trigger then
        return scaffold_trigger
    end

    -- 4. Statement (new line in block)
    local stmt_trigger = check_statement_trigger(line, prev_line, col)
    if stmt_trigger then
        return stmt_trigger
    end

    -- 5. General typing trigger (lowest priority - catches everything else)
    local typing_trigger = check_typing_trigger(line, col, bufnr)
    if typing_trigger then
        return typing_trigger
    end

    return nil
end

---Check if a specific trigger type should be enabled
---@param trigger_type string
---@param enabled_triggers string[]
---@return boolean
function M.is_enabled(trigger_type, enabled_triggers)
    for _, t in ipairs(enabled_triggers) do
        if t == trigger_type then
            return true
        end
    end
    return false
end

---Clear cache for a buffer (call on BufDelete/BufUnload)
---@param bufnr number
function M.clear_cache(bufnr)
    clear_buffer_cache(bufnr)
end

return M
