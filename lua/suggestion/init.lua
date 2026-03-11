-- Code Suggestion System
-- Main orchestrator combining semantic analysis, LSP, knowledge base, and scoring
local M = {}

local semantic = require("suggestion.semantic")
local knowledge = require("suggestion.knowledge")
local lsp = require("suggestion.lsp")
local scoring = require("suggestion.scoring")
local conventions = require("suggestion.learning.conventions")

---@class SuggestionConfig
---@field enabled boolean Enable suggestion system
---@field languages string[] Supported languages
---@field max_suggestions number Maximum suggestions to return
---@field min_score number Minimum score threshold
---@field weights table Scoring weights

local state = {
    config = {
        enabled = true,
        languages = { "java", "typescript", "javascript" },
        max_suggestions = 5,
        min_score = 25,
        weights = nil, -- Use defaults from scoring module
    },
    conventions_cache = {},
    initialized = false,
}

---Setup suggestion system
---@param opts SuggestionConfig|nil
function M.setup(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})

    if state.config.weights then
        scoring.set_weights(state.config.weights)
    end

    state.initialized = true
end

---Get language from filetype
---@param filetype string
---@return string|nil
local function get_language(filetype)
    local map = {
        java = "java",
        typescript = "typescript",
        typescriptreact = "typescript",
        javascript = "typescript", -- Use TS templates for JS too
        javascriptreact = "typescript",
    }
    return map[filetype]
end

---Get suggestions for a method signature
---@param method_name string Method name
---@param return_type string|nil Return type
---@param params string|nil Parameters string
---@param bufnr number|nil Buffer number
---@return table[] Scored and ranked suggestions
function M.get_suggestions(method_name, return_type, params, bufnr)
    if not state.initialized then
        M.setup()
    end

    if not state.config.enabled then
        return {}
    end

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype
    local language = get_language(filetype)

    if not language then
        return {}
    end

    -- 1. Parse method name semantically
    local parsed = semantic.parse(method_name)

    -- 2. Get LSP context
    local lsp_context = lsp.build_context(bufnr)
    if lsp_context and parsed.noun then
        lsp_context = lsp.enrich_context(lsp_context, parsed.noun, bufnr)
    end

    -- 3. Build template context
    local template_context = knowledge.build_context(parsed, lsp_context)

    -- Merge LSP findings into template context
    if lsp_context then
        if lsp_context.repository then
            template_context.repository = lsp_context.repository
            template_context.has_repository = true
        end
        if lsp_context.mapper then
            template_context.mapper = lsp_context.mapper
            template_context.has_mapper = true
        end
        if lsp_context.service then
            template_context.service = lsp_context.service
        end
    end

    -- 4. Find matching templates
    local qualifier_types = {}
    for _, q in ipairs(parsed.qualifiers or {}) do
        table.insert(qualifier_types, q.type)
    end

    local templates = knowledge.find({
        verb = parsed.verb,
        language = language,
        qualifiers = #qualifier_types > 0 and qualifier_types or nil,
    })

    -- 5. Generate suggestions from templates
    local suggestions = {}

    for _, template in ipairs(templates) do
        local rendered = knowledge.render(template, template_context)
        table.insert(suggestions, {
            body = rendered,
            source = "knowledge_base",
            template_id = template.id,
            template = template,
        })
    end

    -- 6. Add heuristic fallback if no templates matched
    if #suggestions == 0 then
        local heuristic = M._generate_heuristic(parsed, template_context, language)
        if heuristic then
            table.insert(suggestions, {
                body = heuristic,
                source = "heuristic",
            })
        end
    end

    -- 7. Get project conventions (if indexer available)
    local project_conventions = M._get_conventions(bufnr)

    -- 8. Score and rank suggestions
    local scoring_context = {
        semantic = parsed,
        lsp_context = lsp_context,
        conventions = project_conventions,
    }

    local ranked = scoring.rank(suggestions, scoring_context)

    -- 9. Filter by minimum score and limit
    local results = {}
    for _, suggestion in ipairs(ranked) do
        if suggestion.score >= state.config.min_score then
            table.insert(results, suggestion)
        end
        if #results >= state.config.max_suggestions then
            break
        end
    end

    return results
end

---Generate heuristic-based suggestion
---@param parsed table Parsed semantic components
---@param context table Template context
---@param language string
---@return string|nil
function M._generate_heuristic(parsed, context, language)
    if not parsed.verb_category then
        return nil
    end

    local heuristics = {
        java = {
            query = string.format("return %s.findById(id).orElseThrow(() -> new ResourceNotFoundException(\"%s not found\"));",
                context.repository, context.entity),
            creation = string.format("return %s.save(%s);", context.repository, context.entityVar),
            mutation = string.format("this.%s = %s;", context.field, context.field),
            deletion = string.format("%s.deleteById(id);", context.repository),
            validation = string.format("return %s != null;", context.entityVar),
            transformation = string.format("return %s.toDto(this);", context.mapper),
            accessor = string.format("return this.%s;", context.field),
        },
        typescript = {
            query = string.format("return this.%s.findById(id);", context.service),
            creation = string.format("return this.http.post<I%s>(`/api/%s`, data);", context.entity, context.endpoint),
            mutation = string.format("this.%s = value;", context.field),
            deletion = string.format("return this.http.delete(`/api/%s/${id}`);", context.endpoint),
            validation = string.format("return %s !== null && %s !== undefined;", context.entityVar, context.entityVar),
            transformation = "return items.map((item) => ({ ...item }));",
            accessor = string.format("return this.%s;", context.field),
        },
    }

    local lang_heuristics = heuristics[language]
    if lang_heuristics then
        return lang_heuristics[parsed.verb_category]
    end

    return nil
end

---Get project conventions
---@param bufnr number
---@return table|nil
function M._get_conventions(bufnr)
    -- Try to get from indexer
    local ok, indexer = pcall(require, "indexer")
    if not ok then
        return nil
    end

    local status = indexer.status()
    if not status.initialized then
        return nil
    end

    local project_id = indexer.get_project_id()
    if not project_id then
        return nil
    end

    -- Check cache
    local cache_key = tostring(project_id)
    if state.conventions_cache[cache_key] then
        return state.conventions_cache[cache_key]
    end

    -- Get db instance from indexer
    local db = indexer.get_db()
    if not db then
        return nil
    end

    -- Learn conventions from indexed code
    local learned = conventions.learn_from_project(db, project_id)
    if learned then
        state.conventions_cache[cache_key] = learned
    end

    return learned
end

---Parse method name (exposed for external use)
---@param method_name string
---@return table
function M.parse(method_name)
    return semantic.parse(method_name)
end

---Get suggestion status
---@return table
function M.status()
    return {
        enabled = state.config.enabled,
        initialized = state.initialized,
        languages = state.config.languages,
    }
end

return M
