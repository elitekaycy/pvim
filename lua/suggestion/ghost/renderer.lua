-- Ghost Text Renderer
-- Renders suggestions as virtual text using extmarks
local M = {}

-- Namespace for extmarks
local ns = vim.api.nvim_create_namespace("suggestion_ghost")

-- Current ghost text state
local state = {
    bufnr = nil,
    extmark_id = nil,
    suggestion = nil,
    suggestions = {},
    current_index = 1,
    line = nil,
    col = nil,
}

-- Highlight group for ghost text
local function setup_highlights()
    vim.api.nvim_set_hl(0, "SuggestionGhost", {
        fg = "#6c7086",
        italic = true,
        default = true,
    })
end

---Clear current ghost text
function M.clear()
    if state.bufnr and state.extmark_id then
        pcall(vim.api.nvim_buf_del_extmark, state.bufnr, ns, state.extmark_id)
    end

    state.extmark_id = nil
    state.suggestion = nil
    state.line = nil
    state.col = nil
end

---Show ghost text at current cursor position
---@param text string Text to show
---@param bufnr number|nil Buffer number
function M.show(text, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Clear any existing ghost text
    M.clear()

    if not text or text == "" then
        return
    end

    -- Get cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1  -- 0-indexed
    local col = cursor[2]

    -- Split text into lines
    local lines = vim.split(text, "\n", { plain = true })

    -- Build virtual text
    local virt_lines = {}

    -- First line goes inline at cursor
    local first_line = lines[1] or ""

    -- Remaining lines as virtual lines below
    for i = 2, #lines do
        table.insert(virt_lines, {{ lines[i], "SuggestionGhost" }})
    end

    -- Create extmark
    local opts = {
        virt_text = {{ first_line, "SuggestionGhost" }},
        virt_text_pos = "overlay",
        hl_mode = "combine",
    }

    if #virt_lines > 0 then
        opts.virt_lines = virt_lines
    end

    local ok, extmark_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, line, col, opts)

    if ok then
        state.bufnr = bufnr
        state.extmark_id = extmark_id
        state.suggestion = text
        state.line = line
        state.col = col
    end
end

---Set multiple suggestions and show the first one
---@param suggestions table[] List of suggestion objects with 'body' field
---@param bufnr number|nil Buffer number
function M.set_suggestions(suggestions, bufnr)
    state.suggestions = suggestions or {}
    state.current_index = 1

    if #state.suggestions > 0 then
        M.show(state.suggestions[1].body, bufnr)
    else
        M.clear()
    end
end

---Show next suggestion
function M.next()
    if #state.suggestions == 0 then
        return
    end

    state.current_index = state.current_index + 1
    if state.current_index > #state.suggestions then
        state.current_index = 1
    end

    M.show(state.suggestions[state.current_index].body, state.bufnr)
end

---Show previous suggestion
function M.prev()
    if #state.suggestions == 0 then
        return
    end

    state.current_index = state.current_index - 1
    if state.current_index < 1 then
        state.current_index = #state.suggestions
    end

    M.show(state.suggestions[state.current_index].body, state.bufnr)
end

---Accept current ghost text (insert it)
---@return boolean success
function M.accept()
    if not state.suggestion or state.suggestion == "" then
        return false
    end

    -- Clear ghost text first
    local text = state.suggestion
    local bufnr = state.bufnr or vim.api.nvim_get_current_buf()
    M.clear()

    -- Get current cursor position
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]
    local col = cursor[2]

    -- Get current line content
    local current_line = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1] or ""

    -- Split suggestion into lines
    local suggestion_lines = vim.split(text, "\n", { plain = true })

    if #suggestion_lines == 1 then
        -- Single line: insert at cursor
        local new_line = current_line:sub(1, col) .. text .. current_line:sub(col + 1)
        vim.api.nvim_buf_set_lines(bufnr, line - 1, line, false, { new_line })
        vim.api.nvim_win_set_cursor(0, { line, col + #text })
    else
        -- Multi-line: insert lines
        local first_line = current_line:sub(1, col) .. suggestion_lines[1]
        local last_line = suggestion_lines[#suggestion_lines] .. current_line:sub(col + 1)

        local new_lines = { first_line }
        for i = 2, #suggestion_lines - 1 do
            table.insert(new_lines, suggestion_lines[i])
        end
        table.insert(new_lines, last_line)

        vim.api.nvim_buf_set_lines(bufnr, line - 1, line, false, new_lines)

        -- Move cursor to end of inserted text
        local new_line_num = line + #suggestion_lines - 1
        local new_col = #suggestion_lines[#suggestion_lines]
        vim.api.nvim_win_set_cursor(0, { new_line_num, new_col })
    end

    -- Clear suggestion state
    state.suggestions = {}
    state.current_index = 1

    return true
end

---Check if ghost text is visible
---@return boolean
function M.is_visible()
    return state.extmark_id ~= nil
end

---Get current suggestion text
---@return string|nil
function M.get_current()
    return state.suggestion
end

---Get number of available suggestions
---@return number
function M.get_count()
    return #state.suggestions
end

---Get current suggestion index
---@return number
function M.get_index()
    return state.current_index
end

-- Setup highlights on module load
setup_highlights()

return M
