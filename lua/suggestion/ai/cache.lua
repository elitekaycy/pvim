-- AI Response Cache
-- Persistent, semantic caching to minimize API calls
local M = {}

local CACHE_DIR = vim.fn.stdpath("cache") .. "/pvim/ai_suggestions"
local CACHE_INDEX = CACHE_DIR .. "/index.json"
local CACHE_TTL = 86400 * 7  -- 7 days for persistent cache
local MEMORY_TTL = 600  -- 10 minutes for memory cache

-- In-memory cache (fast lookups)
local memory_cache = {}

-- Semantic patterns cache (reusable across similar methods)
local pattern_cache = {}

-- Stats
local stats = {
    hits = 0,
    misses = 0,
    pattern_hits = 0,
    saved_tokens = 0,
}

---Ensure cache directory exists
local function ensure_cache_dir()
    vim.fn.mkdir(CACHE_DIR, "p")
end

---Normalize method name to semantic key
---@param method_name string
---@return string semantic_key, table parts
local function semantic_key(method_name)
    -- Parse method name into verb + noun
    local ok, suggestion = pcall(require, "suggestion")
    if not ok then
        return method_name, { verb = method_name, noun = "" }
    end

    local parsed = suggestion.parse(method_name)
    local verb = parsed.verb or ""
    local noun = parsed.noun or ""
    local verb_cat = parsed.verb_category or "unknown"

    -- Normalize noun (strip plurals, common suffixes)
    local normalized_noun = noun:gsub("s$", ""):gsub("ies$", "y")
        :gsub("List$", ""):gsub("Set$", ""):gsub("Map$", "")

    return string.format("%s:%s", verb_cat, normalized_noun), {
        verb = verb,
        noun = noun,
        verb_category = verb_cat,
        normalized_noun = normalized_noun,
    }
end

---Generate context hash (for cache key)
---@param context table
---@return string
local function context_hash(context)
    local parts = {}

    if context.file_context then
        table.insert(parts, context.file_context.class_type or "")
        -- Don't include class_name - makes cache too specific
    end

    if context.framework then
        table.insert(parts, context.framework.id or "")
    end

    return table.concat(parts, ":")
end

---Full cache key
---@param method_name string
---@param context table
---@return string exact_key, string pattern_key
local function cache_keys(method_name, context)
    local sem_key, _ = semantic_key(method_name)
    local ctx_hash = context_hash(context)

    -- Exact key: specific method + context
    local exact = string.format("%s|%s|%s", method_name, sem_key, ctx_hash)

    -- Pattern key: semantic pattern + context type (more reusable)
    local pattern = string.format("%s|%s", sem_key, ctx_hash)

    return exact, pattern
end

---Load persistent cache index
---@return table
local function load_index()
    if vim.fn.filereadable(CACHE_INDEX) == 0 then
        return {}
    end

    local content = vim.fn.readfile(CACHE_INDEX)
    if not content or #content == 0 then
        return {}
    end

    local ok, index = pcall(vim.json.decode, table.concat(content, "\n"))
    if not ok then
        return {}
    end

    return index
end

---Save persistent cache index
---@param index table
local function save_index(index)
    ensure_cache_dir()
    local ok, json = pcall(vim.json.encode, index)
    if ok then
        vim.fn.writefile({ json }, CACHE_INDEX)
    end
end

---Load cached suggestion from disk
---@param key string
---@return string|nil
local function load_from_disk(key)
    local index = load_index()
    local entry = index[key]

    if not entry then
        return nil
    end

    -- Check TTL
    if os.time() - (entry.time or 0) > CACHE_TTL then
        return nil
    end

    -- Load content file
    local content_file = CACHE_DIR .. "/" .. entry.file
    if vim.fn.filereadable(content_file) == 0 then
        return nil
    end

    local content = vim.fn.readfile(content_file)
    if content and #content > 0 then
        return table.concat(content, "\n")
    end

    return nil
end

---Save suggestion to disk
---@param key string
---@param suggestion string
---@param metadata table|nil
local function save_to_disk(key, suggestion, metadata)
    ensure_cache_dir()

    -- Generate filename from key hash
    local filename = vim.fn.sha256(key):sub(1, 16) .. ".txt"

    -- Save content
    vim.fn.writefile(vim.split(suggestion, "\n"), CACHE_DIR .. "/" .. filename)

    -- Update index
    local index = load_index()
    index[key] = {
        file = filename,
        time = os.time(),
        metadata = metadata or {},
    }
    save_index(index)
end

---Get from cache (memory -> disk -> pattern)
---@param method_name string
---@param context table
---@return string|nil suggestion, string|nil source
function M.get(method_name, context)
    local exact_key, pattern_key = cache_keys(method_name, context)

    -- 1. Check memory cache (exact)
    local mem_entry = memory_cache[exact_key]
    if mem_entry and os.time() - mem_entry.time < MEMORY_TTL then
        stats.hits = stats.hits + 1
        return mem_entry.suggestion, "memory"
    end

    -- 2. Check disk cache (exact)
    local disk_result = load_from_disk(exact_key)
    if disk_result then
        -- Promote to memory
        memory_cache[exact_key] = { suggestion = disk_result, time = os.time() }
        stats.hits = stats.hits + 1
        return disk_result, "disk"
    end

    -- 3. Check pattern cache (semantic match)
    local pattern_entry = pattern_cache[pattern_key]
    if pattern_entry then
        -- Adapt pattern to this method
        local adapted = M.adapt_pattern(pattern_entry.template, method_name, context)
        if adapted then
            stats.pattern_hits = stats.pattern_hits + 1
            stats.saved_tokens = stats.saved_tokens + (pattern_entry.tokens or 100)
            return adapted, "pattern"
        end
    end

    stats.misses = stats.misses + 1
    return nil, nil
end

---Store in cache
---@param method_name string
---@param context table
---@param suggestion string
---@param tokens_used number|nil
function M.set(method_name, context, suggestion, tokens_used)
    local exact_key, pattern_key = cache_keys(method_name, context)

    -- Store in memory
    memory_cache[exact_key] = {
        suggestion = suggestion,
        time = os.time(),
    }

    -- Store to disk (async)
    vim.schedule(function()
        save_to_disk(exact_key, suggestion, { tokens = tokens_used })
    end)

    -- Extract and store pattern
    local template = M.extract_pattern(suggestion, method_name, context)
    if template then
        pattern_cache[pattern_key] = {
            template = template,
            tokens = tokens_used,
            time = os.time(),
        }
    end
end

---Extract reusable pattern from suggestion
---@param suggestion string
---@param method_name string
---@param context table
---@return table|nil
function M.extract_pattern(suggestion, method_name, context)
    local sem_key, parts = semantic_key(method_name)

    -- Replace specific names with placeholders
    local template = suggestion

    -- Replace entity name with placeholder
    if parts.noun and parts.noun ~= "" then
        template = template:gsub(parts.noun, "${ENTITY}")
        template = template:gsub(parts.noun:lower(), "${entity}")
    end

    -- Replace field references with type-based placeholders
    if context.file_context and context.file_context.fields then
        for _, field in ipairs(context.file_context.fields) do
            if field.injected then
                template = template:gsub(field.name, "${" .. (field.type or "dependency") .. "}")
            end
        end
    end

    return {
        code = template,
        verb_category = parts.verb_category,
        requires_fields = template:match("%${") ~= nil,
    }
end

---Adapt pattern template to new method
---@param template table
---@param method_name string
---@param context table
---@return string|nil
function M.adapt_pattern(template, method_name, context)
    if not template or not template.code then
        return nil
    end

    local _, parts = semantic_key(method_name)
    local result = template.code

    -- Replace entity placeholder
    if parts.noun and parts.noun ~= "" then
        result = result:gsub("%${ENTITY}", parts.noun)
        result = result:gsub("%${entity}", parts.noun:lower())
    else
        -- Can't adapt without noun
        if result:match("%${ENTITY}") or result:match("%${entity}") then
            return nil
        end
    end

    -- Replace field placeholders
    if context.file_context and context.file_context.fields then
        for _, field in ipairs(context.file_context.fields) do
            if field.injected and field.type then
                result = result:gsub("%${" .. field.type .. "}", field.name)
            end
        end
    end

    -- Check all placeholders resolved
    if result:match("%${") then
        return nil
    end

    return result
end

---Check if method should skip AI (simple getter/setter)
---@param method_name string
---@param context table
---@return boolean skip, string|nil reason
function M.should_skip_ai(method_name, context)
    local _, parts = semantic_key(method_name)

    -- Simple getters - just return the field
    if parts.verb_category == "retrieve" and parts.noun and parts.noun ~= "" then
        if context.file_context and context.file_context.fields then
            for _, field in ipairs(context.file_context.fields) do
                local field_lower = field.name:lower()
                local noun_lower = parts.noun:lower()
                if field_lower == noun_lower or field_lower:match(noun_lower) then
                    return true, string.format("return this.%s;", field.name)
                end
            end
        end
    end

    -- Simple setters
    if parts.verb_category == "mutate" and parts.noun and parts.noun ~= "" then
        local verb = method_name:match("^set") or method_name:match("^update")
        if verb then
            if context.file_context and context.file_context.fields then
                for _, field in ipairs(context.file_context.fields) do
                    local field_lower = field.name:lower()
                    local noun_lower = parts.noun:lower()
                    if field_lower == noun_lower or field_lower:match(noun_lower) then
                        return true, string.format("this.%s = %s;", field.name, field.name)
                    end
                end
            end
        end
    end

    -- toString, hashCode, equals - use standard templates
    if method_name == "toString" or method_name == "hashCode" or method_name == "equals" then
        return true, nil  -- Will use template, not AI
    end

    return false, nil
end

---Clear memory cache
function M.clear_memory()
    memory_cache = {}
    pattern_cache = {}
end

---Clear all caches
function M.clear_all()
    M.clear_memory()
    vim.fn.delete(CACHE_DIR, "rf")
    ensure_cache_dir()
end

---Get cache statistics
---@return table
function M.stats()
    local index = load_index()
    local disk_count = 0
    for _ in pairs(index) do
        disk_count = disk_count + 1
    end

    local mem_count = 0
    for _ in pairs(memory_cache) do
        mem_count = mem_count + 1
    end

    local pattern_count = 0
    for _ in pairs(pattern_cache) do
        pattern_count = pattern_count + 1
    end

    return {
        memory_entries = mem_count,
        disk_entries = disk_count,
        pattern_entries = pattern_count,
        hits = stats.hits,
        misses = stats.misses,
        pattern_hits = stats.pattern_hits,
        saved_tokens = stats.saved_tokens,
        hit_rate = stats.hits + stats.misses > 0
            and math.floor(stats.hits / (stats.hits + stats.misses) * 100)
            or 0,
    }
end

return M
