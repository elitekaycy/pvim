-- Scoring Engine
-- Combines multiple signals to score and rank suggestions
local M = {}

-- Default weights (configurable)
M.weights = {
    semantic = 0.25,      -- Semantic match (verb category alignment)
    template = 0.25,      -- Template priority match
    lsp_context = 0.20,   -- LSP context (uses available symbols)
    convention = 0.15,    -- Project convention adherence
    similarity = 0.15,    -- Similarity to existing code
}

---@class ScoringContext
---@field semantic table Parsed semantic components
---@field lsp_context table|nil LSP-derived context
---@field conventions table|nil Project conventions
---@field template table|nil Matched template

---@class ScoredSuggestion
---@field body string The suggestion body
---@field score number Final score (0-100)
---@field scores table Individual signal scores
---@field source string Source of suggestion
---@field template_id string|nil Template ID if from knowledge base

---Score a single suggestion
---@param suggestion table Raw suggestion {body, source, template_id, template}
---@param context ScoringContext
---@return ScoredSuggestion
function M.score(suggestion, context)
    local scores = {
        semantic = 0,
        template = 0,
        lsp_context = 0,
        convention = 0,
        similarity = 0,
    }

    -- 1. Semantic Match Score (0-25)
    scores.semantic = M._score_semantic(suggestion, context.semantic)

    -- 2. Template Match Score (0-25)
    scores.template = M._score_template(suggestion)

    -- 3. LSP Context Score (0-20)
    scores.lsp_context = M._score_lsp(suggestion, context.lsp_context)

    -- 4. Convention Match Score (0-15)
    scores.convention = M._score_conventions(suggestion, context.conventions)

    -- 5. Similarity Score (0-15)
    scores.similarity = M._score_similarity(suggestion, context)

    -- Calculate weighted final score
    local final_score =
        scores.semantic * M.weights.semantic +
        scores.template * M.weights.template +
        scores.lsp_context * M.weights.lsp_context +
        scores.convention * M.weights.convention +
        scores.similarity * M.weights.similarity

    -- Normalize to 0-100
    final_score = final_score * 4 -- Since max weighted sum is ~25

    return {
        body = suggestion.body,
        score = math.floor(final_score),
        scores = scores,
        source = suggestion.source or "unknown",
        template_id = suggestion.template_id,
    }
end

---Score semantic alignment
---@param suggestion table
---@param semantic table|nil
---@return number 0-25
function M._score_semantic(suggestion, semantic)
    if not semantic then return 12.5 end -- Neutral score

    local score = 0
    local body = suggestion.body

    -- Verb category expectations
    local category_patterns = {
        query = { "return", "find", "get", "select" },
        creation = { "new", "create", "save", "build" },
        mutation = { "set", "=", "update", "this%." },
        deletion = { "delete", "remove", "null" },
        validation = { "if", "throw", "return true", "return false", "!=", "==" },
        transformation = { "map", "convert", "new", "to" },
        processing = { "process", "handle", "execute" },
        communication = { "send", "notify", "publish" },
        calculation = { "return", "+", "-", "*", "/", "sum", "count" },
    }

    if semantic.verb_category then
        local patterns = category_patterns[semantic.verb_category]
        if patterns then
            for _, pattern in ipairs(patterns) do
                if body:match(pattern) then
                    score = score + 4
                end
            end
        end
    end

    -- Noun presence in suggestion
    if semantic.noun and body:match(semantic.noun) then
        score = score + 5
    end

    -- Variable form of noun
    if semantic.noun then
        local var_form = semantic.noun:sub(1, 1):lower() .. semantic.noun:sub(2)
        if body:match(var_form) then
            score = score + 3
        end
    end

    -- Qualifier handling
    if semantic.qualifiers then
        for _, qual in ipairs(semantic.qualifiers) do
            if qual.text and body:match(qual.text) then
                score = score + 3
            end
            if qual.extracted and body:match(qual.extracted) then
                score = score + 2
            end
        end
    end

    return math.min(25, score)
end

---Score template match quality
---@param suggestion table
---@return number 0-25
function M._score_template(suggestion)
    if not suggestion.template then
        return 10 -- Base score for non-template suggestions
    end

    -- Template priority directly influences score
    local priority = suggestion.template.priority or 50
    return (priority / 100) * 25
end

---Score LSP context alignment
---@param suggestion table
---@param lsp_context table|nil
---@return number 0-20
function M._score_lsp(suggestion, lsp_context)
    if not lsp_context then return 10 end -- Neutral

    local score = 5 -- Base score
    local body = suggestion.body

    -- Check if suggestion uses available symbols
    if lsp_context.symbols then
        for _, symbol in ipairs(lsp_context.symbols) do
            if body:match(symbol.name) then
                score = score + 2
            end
        end
    end

    -- Check if uses found repository/service/mapper
    if lsp_context.repository and body:match(lsp_context.repository) then
        score = score + 4
    end
    if lsp_context.service and body:match(lsp_context.service) then
        score = score + 3
    end
    if lsp_context.mapper and body:match(lsp_context.mapper) then
        score = score + 3
    end

    -- Check if uses available fields
    if lsp_context.fields then
        for _, field in ipairs(lsp_context.fields) do
            if body:match(field.name) then
                score = score + 1
            end
        end
    end

    return math.min(20, score)
end

---Score convention adherence
---@param suggestion table
---@param conventions table|nil
---@return number 0-15
function M._score_conventions(suggestion, conventions)
    if not conventions or vim.tbl_isempty(conventions) then
        return 7.5 -- Neutral score
    end

    local score = 5
    local body = suggestion.body

    -- Check each convention
    for pattern_type, convention in pairs(conventions) do
        local follows = M._check_convention(body, pattern_type)
        if follows then
            score = score + (convention.confidence or 0.5) * 5
        end
    end

    return math.min(15, score)
end

---Check if body follows a convention pattern
---@param body string
---@param pattern_type string
---@return boolean
function M._check_convention(body, pattern_type)
    local checks = {
        exception_not_found = function(b) return b:match("NotFoundException") or b:match("ResourceNotFound") end,
        exception_validation = function(b) return b:match("ValidationException") or b:match("IllegalArgument") end,
        log_info = function(b) return b:match("log%.info") end,
        log_debug = function(b) return b:match("log%.debug") end,
        optional_throw = function(b) return b:match("%.orElseThrow") end,
        optional_get = function(b) return b:match("%.orElse%(") or b:match("%.orElseGet") end,
        stream_collect = function(b) return b:match("%.collect%(") end,
        stream_tolist = function(b) return b:match("%.toList%(%)") end,
    }

    local check = checks[pattern_type]
    if check then
        return check(body) ~= nil
    end

    return false
end

---Score similarity to existing project code
---@param suggestion table
---@param context table
---@return number 0-15
function M._score_similarity(suggestion, context)
    local score = 7 -- Base score
    local body = suggestion.body

    -- Reward common good practices
    if body:match("log%.") then score = score + 1 end
    if body:match("%.orElseThrow") then score = score + 2 end
    if body:match("return ") then score = score + 1 end
    if body:match("throw new") then score = score + 1 end

    -- Penalize potentially problematic patterns
    if body:match("null;$") then score = score - 2 end
    if body:match("TODO") then score = score - 1 end
    if body:match("// ") and not body:match("// Add") then score = score - 1 end

    -- Reward completeness
    local line_count = select(2, body:gsub("\n", "\n")) + 1
    if line_count > 1 then score = score + 1 end
    if line_count > 3 then score = score + 1 end

    return math.max(0, math.min(15, score))
end

---Score and rank multiple suggestions
---@param suggestions table[] Raw suggestions
---@param context ScoringContext
---@return ScoredSuggestion[]
function M.rank(suggestions, context)
    local scored = {}

    for _, suggestion in ipairs(suggestions) do
        table.insert(scored, M.score(suggestion, context))
    end

    -- Sort by score descending
    table.sort(scored, function(a, b)
        return a.score > b.score
    end)

    return scored
end

---Configure weights
---@param new_weights table
function M.set_weights(new_weights)
    M.weights = vim.tbl_deep_extend("force", M.weights, new_weights)
end

return M
