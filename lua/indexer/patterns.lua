-- Pattern matching module for project indexer
-- Provides heuristic-based code suggestions
local M = {}

---@class PatternMatcher
---@field db IndexerDB Database instance
---@field project_id number Current project ID
local PatternMatcher = {}
PatternMatcher.__index = PatternMatcher

---Create a new pattern matcher instance
---@param db IndexerDB Database instance
---@param project_id number Project ID
---@return PatternMatcher
function M.new(db, project_id)
    local self = setmetatable({}, PatternMatcher)
    self.db = db
    self.project_id = project_id
    return self
end

---Extract camelCase parts from a name
---@param name string Method/variable name
---@return string[] Parts
local function split_camel_case(name)
    local parts = {}
    local current = ""

    for i = 1, #name do
        local char = name:sub(i, i)
        if char:match("%u") and #current > 0 then
            table.insert(parts, current:lower())
            current = char
        else
            current = current .. char
        end
    end

    if #current > 0 then
        table.insert(parts, current:lower())
    end

    return parts
end

---Check if a name matches a pattern prefix
---@param name string Method name
---@param prefix string Prefix to match (e.g., "get", "set", "is")
---@return string|nil Remainder after prefix
local function match_prefix(name, prefix)
    if name:sub(1, #prefix):lower() == prefix:lower() then
        local remainder = name:sub(#prefix + 1)
        if remainder:match("^%u") then
            return remainder
        end
    end
    return nil
end

---Find matching variables for a field reference
---@param field_name string Field name to match
---@param file_vars table[] Variables in current file
---@return table|nil Best matching variable
function PatternMatcher:find_matching_variable(field_name, file_vars)
    local lower_field = field_name:lower()

    -- Exact match first
    for _, var in ipairs(file_vars) do
        if var.name:lower() == lower_field then
            return var
        end
    end

    -- Partial match
    for _, var in ipairs(file_vars) do
        if var.name:lower():find(lower_field, 1, true) then
            return var
        end
    end

    return nil
end

---Generate getter suggestion
---@param method_name string Method name (e.g., "getName")
---@param return_type string|nil Return type
---@param file_vars table[] Variables in scope
---@return string|nil Suggestion body
function PatternMatcher:suggest_getter(method_name, return_type, file_vars)
    local field = match_prefix(method_name, "get")
    if not field then return nil end

    local field_name = field:sub(1, 1):lower() .. field:sub(2)
    local matched_var = self:find_matching_variable(field_name, file_vars)

    if matched_var then
        return string.format("return this.%s;", matched_var.name)
    end

    -- Fallback: use derived field name
    return string.format("return this.%s;", field_name)
end

---Generate setter suggestion
---@param method_name string Method name (e.g., "setName")
---@param params string|nil Parameter string
---@param file_vars table[] Variables in scope
---@return string|nil Suggestion body
function PatternMatcher:suggest_setter(method_name, params, file_vars)
    local field = match_prefix(method_name, "set")
    if not field then return nil end

    local field_name = field:sub(1, 1):lower() .. field:sub(2)

    -- Try to extract parameter name from params
    local param_name = field_name
    if params then
        local extracted = params:match("([%w_]+)%s*[,%)%]]?$")
        if extracted then
            param_name = extracted
        end
    end

    return string.format("this.%s = %s;", field_name, param_name)
end

---Generate boolean getter suggestion (is/has)
---@param method_name string Method name (e.g., "isActive", "hasItems")
---@param file_vars table[] Variables in scope
---@return string|nil Suggestion body
function PatternMatcher:suggest_boolean_getter(method_name, file_vars)
    local field = match_prefix(method_name, "is") or match_prefix(method_name, "has")
    if not field then return nil end

    local field_name = field:sub(1, 1):lower() .. field:sub(2)
    local matched_var = self:find_matching_variable(field_name, file_vars)

    if matched_var then
        return string.format("return this.%s;", matched_var.name)
    end

    return string.format("return this.%s;", field_name)
end

---Generate builder method suggestion (with*)
---@param method_name string Method name (e.g., "withName")
---@param params string|nil Parameter string
---@return string|nil Suggestion body
function PatternMatcher:suggest_builder(method_name, params)
    local field = match_prefix(method_name, "with")
    if not field then return nil end

    local field_name = field:sub(1, 1):lower() .. field:sub(2)

    return string.format("this.%s = %s;\nreturn this;", field_name, field_name)
end

---Generate calculation suggestion
---@param method_name string Method name (e.g., "calculateTotal")
---@param return_type string|nil Return type
---@param file_vars table[] Variables in scope
---@return string|nil Suggestion body
function PatternMatcher:suggest_calculation(method_name, return_type, file_vars)
    local what = match_prefix(method_name, "calculate")
    if not what then return nil end

    -- Look for numeric variables that might be involved
    local numeric_vars = {}
    for _, var in ipairs(file_vars) do
        local var_type = var.type or ""
        if var_type:match("int") or var_type:match("float")
            or var_type:match("double") or var_type:match("number")
            or var_type:match("Integer") or var_type:match("Double")
        then
            table.insert(numeric_vars, var.name)
        end
    end

    if #numeric_vars >= 2 then
        -- Suggest multiplication or addition based on keywords
        local lower_what = what:lower()
        if lower_what:find("total") or lower_what:find("sum") then
            return string.format("return %s + %s;", numeric_vars[1], numeric_vars[2])
        elseif lower_what:find("product") or lower_what:find("area") then
            return string.format("return %s * %s;", numeric_vars[1], numeric_vars[2])
        elseif lower_what:find("average") or lower_what:find("avg") then
            return string.format("return (%s + %s) / 2;", numeric_vars[1], numeric_vars[2])
        else
            return string.format("return %s * %s;", numeric_vars[1], numeric_vars[2])
        end
    end

    return nil
end

---Generate to* conversion suggestion
---@param method_name string Method name (e.g., "toString", "toDTO")
---@param return_type string|nil Return type
---@return string|nil Suggestion body
function PatternMatcher:suggest_conversion(method_name, return_type)
    local target = match_prefix(method_name, "to")
    if not target then return nil end

    if target == "String" or target == "string" then
        return "return String.valueOf(this);"
    end

    return string.format("return new %s(this);", target)
end

---Get suggestions for a method signature
---@param method_name string Method name
---@param return_type string|nil Return type
---@param params string|nil Parameters string
---@param file string Current file path
---@return table[] Suggestions with score
function PatternMatcher:get_suggestions(method_name, return_type, params, file)
    local suggestions = {}

    -- Get variables in current file for context
    local file_vars = self.db:get_file_variables(self.project_id, file)

    -- Try different pattern matchers
    local matchers = {
        { fn = self.suggest_getter, score = 90 },
        { fn = self.suggest_setter, score = 90 },
        { fn = self.suggest_boolean_getter, score = 85 },
        { fn = self.suggest_builder, score = 80 },
        { fn = self.suggest_calculation, score = 75 },
        { fn = self.suggest_conversion, score = 70 },
    }

    for _, matcher in ipairs(matchers) do
        local suggestion
        if matcher.fn == self.suggest_setter or matcher.fn == self.suggest_builder then
            suggestion = matcher.fn(self, method_name, params, file_vars)
        elseif matcher.fn == self.suggest_conversion then
            suggestion = matcher.fn(self, method_name, return_type)
        else
            suggestion = matcher.fn(self, method_name, return_type, file_vars)
        end

        if suggestion then
            table.insert(suggestions, {
                body = suggestion,
                score = matcher.score,
                source = "heuristic",
            })
        end
    end

    -- Also check database patterns
    local db_patterns = self.db:find_patterns(method_name)
    for _, pattern in ipairs(db_patterns) do
        table.insert(suggestions, {
            body = pattern.suggestion,
            score = pattern.score,
            source = pattern.source,
        })
    end

    -- Sort by score descending
    table.sort(suggestions, function(a, b)
        return a.score > b.score
    end)

    return suggestions
end

---Learn a pattern from existing code
---@param method_name string Method name
---@param body string Method body
---@param context table|nil Additional context
function PatternMatcher:learn_pattern(method_name, body, context)
    if not method_name or not body then return end

    -- Extract pattern trigger from method name
    local trigger = method_name

    -- Generalize to wildcard pattern
    local parts = split_camel_case(method_name)
    if #parts > 1 then
        -- e.g., "getName" -> "get*"
        trigger = parts[1] .. "*"
    end

    -- Normalize body for storage
    local normalized = body:gsub("%s+", " "):gsub("^%s*", ""):gsub("%s*$", "")

    -- Store pattern
    self.db:upsert_pattern(
        self.project_id,
        trigger,
        context and vim.json.encode(context) or nil,
        normalized,
        "project"
    )
end

---Analyze project functions and learn patterns
---@param functions table[] List of indexed functions
function PatternMatcher:analyze_project(functions)
    for _, func in ipairs(functions) do
        if func.body_template and #func.body_template > 10 then
            self:learn_pattern(func.name, func.body_template, {
                return_type = func.return_type,
                params = func.params,
            })
        end
    end
end

return M
