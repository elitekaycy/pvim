-- Convention Detector
-- Learns naming and structural patterns from project code
local M = {}

-- Pattern definitions to detect
M.patterns = {
    -- Exception handling patterns
    {
        id = "exception_not_found",
        type = "structure",
        regex = "throw%s+new%s+%w*NotFoundException",
        template_hint = "Use ${Exception}NotFoundException for not found cases",
    },
    {
        id = "exception_validation",
        type = "structure",
        regex = "throw%s+new%s+%w*ValidationException",
        template_hint = "Use ValidationException for validation errors",
    },
    {
        id = "exception_illegal_argument",
        type = "structure",
        regex = "throw%s+new%s+IllegalArgumentException",
        template_hint = "Use IllegalArgumentException for bad arguments",
    },

    -- Logging patterns
    {
        id = "log_info",
        type = "structure",
        regex = "log%.info%(",
        template_hint = "Use log.info() for informational messages",
    },
    {
        id = "log_debug",
        type = "structure",
        regex = "log%.debug%(",
        template_hint = "Use log.debug() for debug messages",
    },
    {
        id = "log_error",
        type = "structure",
        regex = "log%.error%(",
        template_hint = "Use log.error() for error messages",
    },
    {
        id = "log_slf4j_format",
        type = "structure",
        regex = 'log%.%w+%(".-{}"',
        template_hint = "Use SLF4J {} placeholders for logging",
    },

    -- Optional handling patterns
    {
        id = "optional_throw",
        type = "structure",
        regex = "%.orElseThrow%(",
        template_hint = "Use .orElseThrow() for Optional handling",
    },
    {
        id = "optional_get",
        type = "structure",
        regex = "%.orElse%(",
        template_hint = "Use .orElse() for Optional defaults",
    },
    {
        id = "optional_map",
        type = "structure",
        regex = "%.map%(.-%)%.orElse",
        template_hint = "Use .map().orElse() for Optional transformations",
    },

    -- Stream patterns
    {
        id = "stream_collect_list",
        type = "structure",
        regex = "%.collect%(Collectors%.toList%(%)",
        template_hint = "Use Collectors.toList() for stream collection",
    },
    {
        id = "stream_tolist",
        type = "structure",
        regex = "%.toList%(%)",
        template_hint = "Use .toList() (Java 16+) for stream collection",
    },
    {
        id = "stream_map",
        type = "structure",
        regex = "%.stream%(%)%s*%.map%(",
        template_hint = "Use stream().map() for transformations",
    },
    {
        id = "stream_filter",
        type = "structure",
        regex = "%.stream%(%)%s*%.filter%(",
        template_hint = "Use stream().filter() for filtering",
    },

    -- Repository patterns
    {
        id = "repo_find_by",
        type = "structure",
        regex = "%w+Repository%.findBy%w+%(",
        template_hint = "Use repository.findBy*() for queries",
    },
    {
        id = "repo_save",
        type = "structure",
        regex = "%w+Repository%.save%(",
        template_hint = "Use repository.save() for persistence",
    },
    {
        id = "repo_exists_check",
        type = "structure",
        regex = "if%s*%(!?%s*%w+Repository%.existsBy",
        template_hint = "Use repository.existsBy*() for existence checks",
    },

    -- Naming conventions
    {
        id = "naming_service_suffix",
        type = "naming",
        regex = "%w+Service",
        applies_to = "class",
        template_hint = "Service classes end with 'Service'",
    },
    {
        id = "naming_repository_suffix",
        type = "naming",
        regex = "%w+Repository",
        applies_to = "class",
        template_hint = "Repository interfaces end with 'Repository'",
    },
    {
        id = "naming_dto_suffix",
        type = "naming",
        regex = "%w+Dto",
        applies_to = "class",
        template_hint = "DTOs end with 'Dto'",
    },
    {
        id = "naming_request_suffix",
        type = "naming",
        regex = "%w+Request",
        applies_to = "class",
        template_hint = "Request DTOs end with 'Request'",
    },
    {
        id = "naming_response_suffix",
        type = "naming",
        regex = "%w+Response",
        applies_to = "class",
        template_hint = "Response DTOs end with 'Response'",
    },

    -- TypeScript/JavaScript patterns
    {
        id = "ts_async_await",
        type = "structure",
        regex = "async%s+%w+.-await",
        template_hint = "Use async/await for asynchronous operations",
    },
    {
        id = "ts_arrow_function",
        type = "structure",
        regex = "%)%s*=>%s*{",
        template_hint = "Use arrow functions for callbacks",
    },
    {
        id = "ts_optional_chaining",
        type = "structure",
        regex = "%?%.",
        template_hint = "Use optional chaining (?.) for null safety",
    },
    {
        id = "ts_nullish_coalescing",
        type = "structure",
        regex = "%?%?",
        template_hint = "Use nullish coalescing (??) for defaults",
    },
}

---@class Convention
---@field id string Pattern ID
---@field type string Pattern type (structure, naming)
---@field count number Times detected
---@field confidence number 0.0 to 1.0
---@field examples string[] Example occurrences

-- In-memory cache per project
local conventions_cache = {}

---Analyze function bodies and detect patterns
---@param bodies table[] List of {name, body} pairs
---@return table<string, Convention>
function M.analyze(bodies)
    local pattern_counts = {}
    local total = #bodies

    for _, item in ipairs(bodies) do
        local body = item.body or ""
        local name = item.name or ""

        for _, pattern in ipairs(M.patterns) do
            if body:match(pattern.regex) or (pattern.applies_to and name:match(pattern.regex)) then
                if not pattern_counts[pattern.id] then
                    pattern_counts[pattern.id] = {
                        id = pattern.id,
                        type = pattern.type,
                        count = 0,
                        examples = {},
                        template_hint = pattern.template_hint,
                    }
                end

                pattern_counts[pattern.id].count = pattern_counts[pattern.id].count + 1

                -- Store up to 3 examples
                if #pattern_counts[pattern.id].examples < 3 then
                    table.insert(pattern_counts[pattern.id].examples, name)
                end
            end
        end
    end

    -- Calculate confidence
    local conventions = {}
    for id, data in pairs(pattern_counts) do
        -- Confidence based on frequency
        local confidence = math.min(1.0, data.count / math.max(1, total * 0.1))

        -- Only include patterns with reasonable confidence
        if confidence >= 0.1 or data.count >= 3 then
            conventions[id] = {
                id = id,
                type = data.type,
                count = data.count,
                confidence = confidence,
                examples = data.examples,
                template_hint = data.template_hint,
            }
        end
    end

    return conventions
end

---Learn conventions from indexed functions
---@param db table Database instance
---@param project_id number
---@return table<string, Convention>
function M.learn_from_project(db, project_id)
    -- Check cache first
    local cache_key = tostring(project_id)
    if conventions_cache[cache_key] then
        return conventions_cache[cache_key]
    end

    -- Query all functions with body templates (use raw SQL to avoid sqlite.lua schema issues)
    local functions = db.db:eval(
        "SELECT name, body_template FROM functions WHERE project_id = ? AND body_template IS NOT NULL",
        { project_id }
    )

    if not functions or type(functions) ~= "table" or #functions == 0 then
        return {}
    end

    -- Prepare bodies for analysis
    local bodies = {}
    for _, func in ipairs(functions) do
        if func.body_template and #func.body_template > 5 then
            table.insert(bodies, {
                name = func.name,
                body = func.body_template,
            })
        end
    end

    -- Analyze
    local conventions = M.analyze(bodies)

    -- Cache result
    conventions_cache[cache_key] = conventions

    return conventions
end

---Clear cache for a project
---@param project_id number
function M.clear_cache(project_id)
    conventions_cache[tostring(project_id)] = nil
end

---Get convention template hints for scoring
---@param conventions table<string, Convention>
---@return table<string, string> Pattern hints
function M.get_hints(conventions)
    local hints = {}
    for id, conv in pairs(conventions) do
        if conv.template_hint then
            hints[id] = conv.template_hint
        end
    end
    return hints
end

---Check if a suggestion follows detected conventions
---@param body string Suggestion body
---@param conventions table<string, Convention>
---@return number score 0.0 to 1.0
function M.score_adherence(body, conventions)
    if not conventions or vim.tbl_isempty(conventions) then
        return 0.5 -- Neutral
    end

    local matches = 0
    local total_confidence = 0

    for id, conv in pairs(conventions) do
        -- Find pattern definition
        for _, pattern in ipairs(M.patterns) do
            if pattern.id == id then
                if body:match(pattern.regex) then
                    matches = matches + conv.confidence
                end
                total_confidence = total_confidence + conv.confidence
                break
            end
        end
    end

    if total_confidence == 0 then
        return 0.5
    end

    return matches / total_confidence
end

return M
