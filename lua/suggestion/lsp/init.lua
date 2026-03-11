-- LSP Integration Module
-- Queries LSP for symbols, types, and context
local M = {}

-- Cache for type information
local type_cache = {}
local cache_ttl = 60000 -- 60 seconds

---@class LSPContext
---@field symbols table[] Symbols in scope
---@field repository string|nil Repository variable name
---@field service string|nil Service variable name
---@field mapper string|nil Mapper variable name
---@field fields table[] Class fields
---@field methods table[] Available methods
---@field expected_return_type string|nil Expected return type

---Get LSP client for current buffer
---@param bufnr number|nil Buffer number
---@return table|nil client
---@return string|nil filetype
function M.get_client(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    for _, client in ipairs(clients) do
        -- Prefer language-specific servers
        if client.name == "jdtls" or client.name == "ts_ls" or client.name == "typescript-language-server" then
            return client, vim.bo[bufnr].filetype
        end
    end

    -- Fallback to any LSP client
    if #clients > 0 then
        return clients[1], vim.bo[bufnr].filetype
    end

    return nil, nil
end

---Get document symbols for current buffer
---@param client table LSP client
---@param bufnr number Buffer number
---@return table[] symbols
function M.get_document_symbols(client, bufnr)
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

    local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 2000)

    if not result then
        return {}
    end

    local symbols = {}
    for _, res in pairs(result) do
        if res.result then
            M._flatten_symbols(res.result, symbols)
        end
    end

    return symbols
end

---Flatten nested symbols
---@param symbols table[]
---@param output table[]
---@param parent string|nil Parent name for context
function M._flatten_symbols(symbols, output, parent)
    for _, symbol in ipairs(symbols) do
        local entry = {
            name = symbol.name,
            kind = symbol.kind,
            kind_name = M._symbol_kind_name(symbol.kind),
            detail = symbol.detail,
            range = symbol.range or (symbol.location and symbol.location.range),
            parent = parent,
        }
        table.insert(output, entry)

        -- Recurse into children
        if symbol.children then
            M._flatten_symbols(symbol.children, output, symbol.name)
        end
    end
end

---Get symbol kind name
---@param kind number LSP SymbolKind
---@return string
function M._symbol_kind_name(kind)
    local kinds = {
        [1] = "File", [2] = "Module", [3] = "Namespace", [4] = "Package",
        [5] = "Class", [6] = "Method", [7] = "Property", [8] = "Field",
        [9] = "Constructor", [10] = "Enum", [11] = "Interface", [12] = "Function",
        [13] = "Variable", [14] = "Constant", [15] = "String", [16] = "Number",
        [17] = "Boolean", [18] = "Array", [19] = "Object", [20] = "Key",
        [21] = "Null", [22] = "EnumMember", [23] = "Struct", [24] = "Event",
        [25] = "Operator", [26] = "TypeParameter",
    }
    return kinds[kind] or "Unknown"
end

---Get symbols in scope at a position
---@param client table LSP client
---@param bufnr number Buffer number
---@param position table {line, character}
---@return table[] symbols
function M.get_symbols_in_scope(client, bufnr, position)
    local all_symbols = M.get_document_symbols(client, bufnr)
    local in_scope = {}

    for _, symbol in ipairs(all_symbols) do
        -- Check if symbol is visible at position
        if M._is_in_scope(symbol, position) then
            table.insert(in_scope, symbol)
        end
    end

    return in_scope
end

---Check if symbol is in scope at position
---@param symbol table
---@param position table
---@return boolean
function M._is_in_scope(symbol, position)
    -- Fields and methods are always in scope within class
    if symbol.kind == 8 or symbol.kind == 6 then -- Field or Method
        return true
    end

    -- Variables: check range
    if symbol.range then
        local start_line = symbol.range.start.line
        local end_line = symbol.range["end"].line
        return position.line >= start_line and position.line <= end_line
    end

    return true -- Default: assume in scope
end

---Find related types for an entity (Repository, Service, Mapper, etc.)
---@param client table LSP client
---@param bufnr number Buffer number
---@param entity_name string Entity name (e.g., "User")
---@return table related
function M.find_related_types(client, bufnr, entity_name)
    local related = {
        repository = nil,
        service = nil,
        mapper = nil,
        dto = nil,
        controller = nil,
    }

    -- Get all symbols in document
    local symbols = M.get_document_symbols(client, bufnr)

    -- Look for fields matching pattern
    local suffixes = {
        { field = "repository", pattern = entity_name .. "Repository", var_pattern = entity_name:lower() .. "Repository" },
        { field = "service", pattern = entity_name .. "Service", var_pattern = entity_name:lower() .. "Service" },
        { field = "mapper", pattern = entity_name .. "Mapper", var_pattern = entity_name:lower() .. "Mapper" },
    }

    for _, symbol in ipairs(symbols) do
        -- Check fields (kind = 8)
        if symbol.kind == 8 then
            for _, suffix in ipairs(suffixes) do
                -- Match by name or detail (type)
                if symbol.name:match(suffix.var_pattern) or
                   (symbol.detail and symbol.detail:match(suffix.pattern)) then
                    related[suffix.field] = symbol.name
                end
            end
        end
    end

    -- Also try workspace symbol search for broader context
    M._search_workspace_types(client, bufnr, entity_name, related)

    return related
end

---Search workspace for related types
---@param client table
---@param bufnr number
---@param entity_name string
---@param related table
function M._search_workspace_types(client, bufnr, entity_name, related)
    -- Skip if all found
    if related.repository and related.service and related.mapper then
        return
    end

    local suffixes = { "Repository", "Service", "Mapper" }

    for _, suffix in ipairs(suffixes) do
        local field = suffix:lower()
        if not related[field] then
            local query = entity_name .. suffix
            local result = vim.lsp.buf_request_sync(bufnr, "workspace/symbol", { query = query }, 1000)

            if result then
                for _, res in pairs(result) do
                    if res.result and #res.result > 0 then
                        for _, symbol in ipairs(res.result) do
                            if symbol.name == query or symbol.name:match(query .. "$") then
                                -- Found the type, derive variable name
                                related[field] = entity_name:sub(1, 1):lower() .. entity_name:sub(2) .. suffix
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

---Get methods from a type/class
---@param client table LSP client
---@param bufnr number Buffer number
---@param type_name string Type name to search
---@return table[] methods
function M.get_type_methods(client, bufnr, type_name)
    local methods = {}

    -- Search workspace for the type
    local result = vim.lsp.buf_request_sync(bufnr, "workspace/symbol", { query = type_name }, 2000)

    if not result then
        return methods
    end

    for _, res in pairs(result) do
        if res.result then
            for _, symbol in ipairs(res.result) do
                if symbol.name == type_name and symbol.location then
                    -- Found the type, now get its methods
                    local uri = symbol.location.uri
                    local target_bufnr = vim.uri_to_bufnr(uri)

                    -- Load buffer if needed
                    if not vim.api.nvim_buf_is_loaded(target_bufnr) then
                        vim.fn.bufload(target_bufnr)
                    end

                    -- Get document symbols from that file
                    local symbols = M.get_document_symbols(client, target_bufnr)
                    for _, s in ipairs(symbols) do
                        if s.parent == type_name and s.kind == 6 then -- Method
                            table.insert(methods, {
                                name = s.name,
                                detail = s.detail,
                            })
                        end
                    end
                    break
                end
            end
        end
    end

    return methods
end

---Build LSP context for suggestions
---@param bufnr number|nil
---@return LSPContext|nil
function M.build_context(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local client, ft = M.get_client(bufnr)

    if not client then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local position = { line = cursor[1] - 1, character = cursor[2] }

    local symbols = M.get_symbols_in_scope(client, bufnr, position)

    -- Extract fields and methods
    local fields = {}
    local methods = {}

    for _, symbol in ipairs(symbols) do
        if symbol.kind == 8 then -- Field
            table.insert(fields, symbol)
        elseif symbol.kind == 6 then -- Method
            table.insert(methods, symbol)
        end
    end

    return {
        symbols = symbols,
        fields = fields,
        methods = methods,
        repository = nil, -- Will be set by find_related_types
        service = nil,
        mapper = nil,
    }
end

---Enrich context with entity-specific types
---@param context LSPContext
---@param entity_name string
---@param bufnr number|nil
---@return LSPContext
function M.enrich_context(context, entity_name, bufnr)
    if not context or not entity_name then
        return context or {}
    end

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local client = M.get_client(bufnr)

    if not client then
        return context
    end

    local related = M.find_related_types(client, bufnr, entity_name)

    context.repository = related.repository
    context.service = related.service
    context.mapper = related.mapper

    return context
end

return M
