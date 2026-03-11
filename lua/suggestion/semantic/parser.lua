-- Semantic Method Name Parser
-- Parses method names into verb/noun/qualifier components
local M = {}

-- Verb taxonomy with categories and expected patterns
M.verb_taxonomy = {
    query = {
        verbs = { "find", "get", "fetch", "load", "read", "retrieve", "search", "lookup", "query", "select" },
        expects_return = true,
        typical_patterns = { "repository_call", "service_delegation" },
    },
    creation = {
        verbs = { "create", "make", "build", "generate", "new", "add", "insert", "save", "register" },
        expects_return = true,
        typical_patterns = { "constructor_call", "builder_pattern", "factory_call", "repository_save" },
    },
    mutation = {
        verbs = { "update", "set", "modify", "change", "edit", "patch", "put", "replace" },
        expects_return = false,
        typical_patterns = { "field_assignment", "repository_save" },
    },
    deletion = {
        verbs = { "delete", "remove", "clear", "destroy", "purge", "drop", "unregister" },
        expects_return = false,
        typical_patterns = { "repository_delete", "null_assignment" },
    },
    validation = {
        verbs = { "validate", "check", "verify", "ensure", "assert", "confirm", "is", "has", "can", "should" },
        expects_return = true,
        return_type = "boolean",
        typical_patterns = { "boolean_check", "exception_throw" },
    },
    transformation = {
        verbs = { "convert", "transform", "map", "parse", "format", "serialize", "deserialize", "to", "from", "as" },
        expects_return = true,
        typical_patterns = { "mapper_call", "constructor_mapping", "builder_pattern" },
    },
    processing = {
        verbs = { "process", "handle", "execute", "run", "perform", "do", "apply", "invoke" },
        expects_return = false,
        typical_patterns = { "service_orchestration", "event_handling" },
    },
    communication = {
        verbs = { "send", "notify", "publish", "emit", "dispatch", "broadcast", "post", "push" },
        expects_return = false,
        typical_patterns = { "event_publish", "notification_send", "http_call" },
    },
    calculation = {
        verbs = { "calculate", "compute", "sum", "count", "average", "total", "aggregate", "reduce" },
        expects_return = true,
        typical_patterns = { "numeric_calculation", "stream_reduction" },
    },
}

-- Qualifier patterns with semantic types
M.qualifier_patterns = {
    filter = {
        patterns = { "^By(%u%w*)", "^With(%u%w*)", "^For(%u%w*)", "^Where(%u%w*)", "^Having(%u%w*)" },
        semantic = "filter_condition",
    },
    aggregation = {
        patterns = { "^All$", "^Every$", "^Total$", "^Sum$", "^Count$", "^Average$", "^List$" },
        semantic = "aggregation",
    },
    scope = {
        patterns = { "^First$", "^Last$", "^Top%d*$", "^Recent$", "^Latest$", "^Active$", "^Enabled$", "^Deleted$", "^Valid$", "^Invalid$" },
        semantic = "scope_modifier",
    },
    ordering = {
        patterns = { "^Ordered$", "^Sorted$", "^Asc$", "^Desc$", "^By(%u%w*)Order$" },
        semantic = "ordering",
    },
    negation = {
        patterns = { "^Not(%u%w*)", "^Without(%u%w*)", "^Except(%u%w*)" },
        semantic = "negation",
    },
}

---@class SemanticComponents
---@field original string Original method name
---@field verb string|nil Extracted verb
---@field verb_category string|nil Category of the verb
---@field verb_info table|nil Full verb taxonomy info
---@field noun string|nil Main entity/noun
---@field noun_plural boolean Whether noun appears to be plural
---@field qualifiers table[] List of qualifiers with type info
---@field raw_parts string[] CamelCase parts

---Parse a method name into semantic components
---@param method_name string
---@return SemanticComponents
function M.parse(method_name)
    local result = {
        original = method_name,
        verb = nil,
        verb_category = nil,
        verb_info = nil,
        noun = nil,
        noun_plural = false,
        qualifiers = {},
        raw_parts = {},
    }

    -- Split camelCase
    result.raw_parts = M.split_camel_case(method_name)

    if #result.raw_parts == 0 then
        return result
    end

    -- Extract verb (first part, lowercase)
    local potential_verb = result.raw_parts[1]:lower()
    result.verb, result.verb_category, result.verb_info = M.classify_verb(potential_verb)

    -- Extract noun and qualifiers from remaining parts
    local remaining = {}
    for i = 2, #result.raw_parts do
        table.insert(remaining, result.raw_parts[i])
    end

    if #remaining > 0 then
        result.noun, result.qualifiers = M.extract_noun_and_qualifiers(remaining)
        if result.noun then
            result.noun_plural = M.is_plural(result.noun)
        end
    end

    return result
end

---Split camelCase/PascalCase into parts
---@param name string
---@return string[]
function M.split_camel_case(name)
    local parts = {}
    local current = ""

    for i = 1, #name do
        local char = name:sub(i, i)
        if char:match("%u") and #current > 0 then
            -- Check for acronyms (consecutive uppercase)
            local prev_char = name:sub(i - 1, i - 1)
            if prev_char:match("%u") then
                -- Check if next char is lowercase (end of acronym)
                local next_char = name:sub(i + 1, i + 1)
                if next_char and next_char:match("%l") then
                    table.insert(parts, current)
                    current = char
                else
                    current = current .. char
                end
            else
                table.insert(parts, current)
                current = char
            end
        else
            current = current .. char
        end
    end

    if #current > 0 then
        table.insert(parts, current)
    end

    return parts
end

---Classify a verb into its category
---@param verb string Lowercase verb
---@return string|nil verb
---@return string|nil category
---@return table|nil verb_info
function M.classify_verb(verb)
    for category, info in pairs(M.verb_taxonomy) do
        for _, v in ipairs(info.verbs) do
            if verb == v then
                return verb, category, info
            end
        end
    end
    -- Return verb even if unclassified
    return verb, nil, nil
end

---Extract noun and qualifiers from remaining parts
---@param parts string[]
---@return string|nil noun
---@return table[] qualifiers
function M.extract_noun_and_qualifiers(parts)
    local qualifiers = {}
    local noun_parts = {}
    local in_qualifier = false
    local qualifier_start = nil

    for i, part in ipairs(parts) do
        -- Check if this starts a qualifier
        local is_qualifier_start, qualifier_type, extracted = M.check_qualifier(part)

        if is_qualifier_start then
            in_qualifier = true
            qualifier_start = i
            -- Collect all remaining parts as qualifier text
            local qualifier_text = table.concat(parts, "", i)
            table.insert(qualifiers, {
                text = qualifier_text,
                type = qualifier_type,
                extracted = extracted,
                raw_part = part,
            })
            break -- Stop processing, rest is qualifier
        else
            table.insert(noun_parts, part)
        end
    end

    local noun = #noun_parts > 0 and table.concat(noun_parts, "") or nil
    return noun, qualifiers
end

---Check if a part is a qualifier
---@param part string
---@return boolean is_qualifier
---@return string|nil qualifier_type
---@return string|nil extracted_value
function M.check_qualifier(part)
    for qtype, qinfo in pairs(M.qualifier_patterns) do
        for _, pattern in ipairs(qinfo.patterns) do
            local match = part:match(pattern)
            if match then
                return true, qinfo.semantic, match
            end
            -- Also check exact match for patterns without captures
            if part:match("^" .. pattern:gsub("%^", ""):gsub("%$", "") .. "$") then
                return true, qinfo.semantic, part
            end
        end
    end
    return false, nil, nil
end

---Check if a noun is plural
---@param noun string|nil
---@return boolean
function M.is_plural(noun)
    if not noun then return false end
    local lower = noun:lower()

    -- Common plural patterns
    if lower:match("ies$") then return true end -- categories
    if lower:match("es$") and not lower:match("ss$") then return true end -- boxes
    if lower:match("s$") and not lower:match("ss$") and not lower:match("us$") then
        -- Ends in 's' but not 'ss' or 'us'
        return true
    end

    -- Common irregular plurals
    local irregulars = { "people", "children", "men", "women", "data", "criteria" }
    for _, irregular in ipairs(irregulars) do
        if lower == irregular then return true end
    end

    return false
end

---Get the singular form of a noun (best effort)
---@param noun string
---@return string
function M.singularize(noun)
    if not noun then return noun end

    local lower = noun:lower()
    local original_case = noun:sub(1, 1):match("%u") and "pascal" or "camel"

    local singular = lower

    -- Handle common patterns
    if lower:match("ies$") then
        singular = lower:gsub("ies$", "y")
    elseif lower:match("es$") and (lower:match("xes$") or lower:match("ches$") or lower:match("shes$")) then
        singular = lower:gsub("es$", "")
    elseif lower:match("s$") and not lower:match("ss$") and not lower:match("us$") then
        singular = lower:gsub("s$", "")
    end

    -- Restore case
    if original_case == "pascal" then
        singular = singular:sub(1, 1):upper() .. singular:sub(2)
    end

    return singular
end

---Convert noun to variable name (camelCase)
---@param noun string
---@return string
function M.to_variable_name(noun)
    if not noun or #noun == 0 then return "item" end
    return noun:sub(1, 1):lower() .. noun:sub(2)
end

---Get expected patterns for a parsed method
---@param parsed SemanticComponents
---@return string[] patterns
function M.get_expected_patterns(parsed)
    if parsed.verb_info then
        return parsed.verb_info.typical_patterns or {}
    end
    return {}
end

---Check if method expects a return value
---@param parsed SemanticComponents
---@return boolean
function M.expects_return(parsed)
    if parsed.verb_info then
        return parsed.verb_info.expects_return ~= false
    end
    -- Default: assume return expected
    return true
end

---Get suggested return type based on verb
---@param parsed SemanticComponents
---@return string|nil
function M.suggested_return_type(parsed)
    if parsed.verb_info and parsed.verb_info.return_type then
        return parsed.verb_info.return_type
    end
    return nil
end

return M
