-- Knowledge Base Templates
-- Pre-defined implementation templates for common patterns
local M = {}

---@class Template
---@field id string Unique identifier
---@field category string Category (repository_query, validation, etc.)
---@field language string Target language (java, typescript)
---@field verb string|string[] Trigger verb(s)
---@field noun_type string|nil Required noun type
---@field qualifiers string[]|nil Required qualifier types
---@field template string Template body with placeholders
---@field context_requirements table Required context
---@field priority number Higher = preferred (1-100)

-- Placeholder syntax:
-- ${entity} - Entity name (e.g., "User")
-- ${entityVar} - Entity variable (e.g., "user")
-- ${repository} - Repository variable (e.g., "userRepository")
-- ${service} - Service variable (e.g., "userService")
-- ${mapper} - Mapper variable (e.g., "userMapper")
-- ${qualifier} - Extracted qualifier (e.g., "Email")
-- ${qualifierVar} - Lowercase qualifier (e.g., "email")
-- ${returnType} - Return type
-- ${param} - First parameter name
-- ${field} - Field name derived from method

M.builtin = {
    -- ═══════════════════════════════════════════════════════════════════
    -- JAVA TEMPLATES
    -- ═══════════════════════════════════════════════════════════════════

    -- Repository Query: find/get with filter
    {
        id = "java.repo.find_by_filter",
        category = "repository_query",
        language = "java",
        verb = { "find", "get", "fetch", "load" },
        qualifiers = { "filter_condition" },
        template = [[return ${repository}.findBy${qualifier}(${qualifierVar})
    .orElseThrow(() -> new ResourceNotFoundException("${entity} not found by ${qualifierVar}: " + ${qualifierVar}));]],
        context_requirements = { has_repository = true, has_qualifier = true },
        priority = 95,
    },

    -- Repository Query: find by ID
    {
        id = "java.repo.find_by_id",
        category = "repository_query",
        language = "java",
        verb = { "find", "get", "fetch", "load" },
        template = [[return ${repository}.findById(id)
    .orElseThrow(() -> new ResourceNotFoundException("${entity} not found: " + id));]],
        context_requirements = { has_repository = true, param_includes = "id" },
        priority = 90,
    },

    -- Repository Query: find all
    {
        id = "java.repo.find_all",
        category = "repository_query",
        language = "java",
        verb = { "find", "get", "fetch", "load" },
        qualifiers = { "aggregation" },
        template = [[return ${repository}.findAll();]],
        context_requirements = { has_repository = true },
        priority = 85,
    },

    -- Repository Query: find with pagination
    {
        id = "java.repo.find_paginated",
        category = "repository_query",
        language = "java",
        verb = { "find", "get", "fetch", "search" },
        template = [[return ${repository}.findAll(pageable);]],
        context_requirements = { has_repository = true, param_includes = "pageable" },
        priority = 88,
    },

    -- Service: create entity
    {
        id = "java.service.create",
        category = "service_call",
        language = "java",
        verb = { "create", "add", "register", "save" },
        template = [[log.info("Creating ${entity}");
${entity} entity = ${mapper}.toEntity(dto);
${entity} saved = ${repository}.save(entity);
return ${mapper}.toDto(saved);]],
        context_requirements = { has_repository = true, has_mapper = true },
        priority = 90,
    },

    -- Service: create without mapper
    {
        id = "java.service.create_simple",
        category = "service_call",
        language = "java",
        verb = { "create", "add", "save" },
        template = [[log.info("Creating ${entity}");
return ${repository}.save(${entityVar});]],
        context_requirements = { has_repository = true },
        priority = 75,
    },

    -- Service: update entity
    {
        id = "java.service.update",
        category = "service_call",
        language = "java",
        verb = { "update", "modify", "edit", "patch" },
        template = [[log.info("Updating ${entity}: {}", id);
${entity} entity = ${repository}.findById(id)
    .orElseThrow(() -> new ResourceNotFoundException("${entity} not found: " + id));
${mapper}.updateEntity(dto, entity);
return ${mapper}.toDto(${repository}.save(entity));]],
        context_requirements = { has_repository = true, has_mapper = true },
        priority = 90,
    },

    -- Service: update simple
    {
        id = "java.service.update_simple",
        category = "service_call",
        language = "java",
        verb = { "update", "modify", "save" },
        template = [[log.info("Updating ${entity}: {}", ${entityVar}.getId());
return ${repository}.save(${entityVar});]],
        context_requirements = { has_repository = true },
        priority = 75,
    },

    -- Service: delete entity
    {
        id = "java.service.delete",
        category = "service_call",
        language = "java",
        verb = { "delete", "remove" },
        template = [[log.info("Deleting ${entity}: {}", id);
if (!${repository}.existsById(id)) {
    throw new ResourceNotFoundException("${entity} not found: " + id);
}
${repository}.deleteById(id);]],
        context_requirements = { has_repository = true },
        priority = 90,
    },

    -- Validation: is/has boolean check
    {
        id = "java.validation.is_has",
        category = "validation",
        language = "java",
        verb = { "is", "has", "can", "should" },
        template = [[return this.${field} != null;]],
        context_requirements = {},
        priority = 80,
    },

    -- Validation: validate entity
    {
        id = "java.validation.validate",
        category = "validation",
        language = "java",
        verb = { "validate", "check", "verify" },
        template = [[if (${entityVar} == null) {
    throw new ValidationException("${entity} cannot be null");
}
// Add validation rules
return true;]],
        context_requirements = {},
        priority = 75,
    },

    -- Validation: check exists
    {
        id = "java.validation.exists",
        category = "validation",
        language = "java",
        verb = { "check", "verify", "ensure" },
        template = [[if (!${repository}.existsById(id)) {
    throw new ResourceNotFoundException("${entity} not found: " + id);
}]],
        context_requirements = { has_repository = true },
        priority = 80,
    },

    -- Conversion: toDto
    {
        id = "java.conversion.to_dto",
        category = "conversion",
        language = "java",
        verb = { "to", "convert", "map" },
        template = [[return ${mapper}.toDto(this);]],
        context_requirements = { has_mapper = true },
        priority = 85,
    },

    -- Conversion: toDto manual
    {
        id = "java.conversion.to_dto_manual",
        category = "conversion",
        language = "java",
        verb = { "to", "convert" },
        template = [[return ${entity}Dto.builder()
    .id(this.id)
    // Add field mappings
    .build();]],
        context_requirements = {},
        priority = 70,
    },

    -- Conversion: fromDto
    {
        id = "java.conversion.from_dto",
        category = "conversion",
        language = "java",
        verb = { "from" },
        template = [[return ${mapper}.toEntity(dto);]],
        context_requirements = { has_mapper = true },
        priority = 85,
    },

    -- Builder: with field
    {
        id = "java.builder.with",
        category = "builder",
        language = "java",
        verb = { "with" },
        template = [[this.${field} = ${field};
return this;]],
        context_requirements = {},
        priority = 95,
    },

    -- Getter
    {
        id = "java.getter",
        category = "accessor",
        language = "java",
        verb = { "get" },
        template = [[return this.${field};]],
        context_requirements = {},
        priority = 90,
    },

    -- Setter
    {
        id = "java.setter",
        category = "accessor",
        language = "java",
        verb = { "set" },
        template = [[this.${field} = ${field};]],
        context_requirements = {},
        priority = 90,
    },

    -- Calculation: sum/total
    {
        id = "java.calculation.sum",
        category = "calculation",
        language = "java",
        verb = { "calculate", "compute", "sum", "total" },
        template = [[return items.stream()
    .map(${entity}::getAmount)
    .reduce(BigDecimal.ZERO, BigDecimal::add);]],
        context_requirements = { has_collection = true },
        priority = 75,
    },

    -- Calculation: count
    {
        id = "java.calculation.count",
        category = "calculation",
        language = "java",
        verb = { "count" },
        template = [[return ${repository}.count();]],
        context_requirements = { has_repository = true },
        priority = 80,
    },

    -- Processing: handle/process
    {
        id = "java.processing.handle",
        category = "processing",
        language = "java",
        verb = { "process", "handle", "execute" },
        template = [[log.info("Processing ${entity}");
// Process logic here
return result;]],
        context_requirements = {},
        priority = 60,
    },

    -- Communication: send notification
    {
        id = "java.communication.send",
        category = "communication",
        language = "java",
        verb = { "send", "notify", "publish" },
        template = [[log.info("Sending ${entity} notification");
notificationService.send(notification);]],
        context_requirements = {},
        priority = 70,
    },

    -- ═══════════════════════════════════════════════════════════════════
    -- TYPESCRIPT TEMPLATES
    -- ═══════════════════════════════════════════════════════════════════

    -- Async fetch
    {
        id = "ts.async.fetch",
        category = "async_operation",
        language = "typescript",
        verb = { "fetch", "load", "get" },
        template = [[const response = await this.${service}.get${entity}(${param});
return response.data;]],
        context_requirements = { is_async = true },
        priority = 85,
    },

    -- HTTP GET
    {
        id = "ts.http.get",
        category = "http_call",
        language = "typescript",
        verb = { "get", "fetch", "find" },
        template = [[return this.http.get<${entity}>(`/api/${endpoint}/${id}`);]],
        context_requirements = { has_http_client = true },
        priority = 80,
    },

    -- HTTP GET all
    {
        id = "ts.http.get_all",
        category = "http_call",
        language = "typescript",
        verb = { "get", "fetch", "find", "load" },
        qualifiers = { "aggregation" },
        template = [[return this.http.get<${entity}[]>(`/api/${endpoint}`);]],
        context_requirements = { has_http_client = true },
        priority = 80,
    },

    -- HTTP POST (create)
    {
        id = "ts.http.post",
        category = "http_call",
        language = "typescript",
        verb = { "create", "add", "save", "post" },
        template = [[return this.http.post<${entity}>(`/api/${endpoint}`, data);]],
        context_requirements = { has_http_client = true },
        priority = 80,
    },

    -- HTTP PUT (update)
    {
        id = "ts.http.put",
        category = "http_call",
        language = "typescript",
        verb = { "update", "modify", "put" },
        template = [[return this.http.put<${entity}>(`/api/${endpoint}/${id}`, data);]],
        context_requirements = { has_http_client = true },
        priority = 80,
    },

    -- HTTP DELETE
    {
        id = "ts.http.delete",
        category = "http_call",
        language = "typescript",
        verb = { "delete", "remove" },
        template = [[return this.http.delete(`/api/${endpoint}/${id}`);]],
        context_requirements = { has_http_client = true },
        priority = 80,
    },

    -- Validation: is/has
    {
        id = "ts.validation.is_has",
        category = "validation",
        language = "typescript",
        verb = { "is", "has", "can" },
        template = [[return ${entityVar} !== null && ${entityVar} !== undefined;]],
        context_requirements = {},
        priority = 75,
    },

    -- Validation: validate
    {
        id = "ts.validation.validate",
        category = "validation",
        language = "typescript",
        verb = { "validate", "check" },
        template = [[if (!${entityVar}) {
  throw new Error('${entity} is required');
}
return true;]],
        context_requirements = {},
        priority = 70,
    },

    -- Event handler
    {
        id = "ts.event.handle",
        category = "event_handler",
        language = "typescript",
        verb = { "handle", "on" },
        template = [[console.log('Handling ${entity} event:', event);
// Handle event logic]],
        context_requirements = {},
        priority = 70,
    },

    -- Transform: map array
    {
        id = "ts.transform.map",
        category = "transformation",
        language = "typescript",
        verb = { "map", "transform" },
        template = [[return items.map((item) => ({
  ...item,
  // Add transformations
}));]],
        context_requirements = { has_array_input = true },
        priority = 75,
    },

    -- Transform: filter array
    {
        id = "ts.transform.filter",
        category = "transformation",
        language = "typescript",
        verb = { "filter" },
        template = [[return items.filter((item) => {
  return item.${field} === value;
});]],
        context_requirements = { has_array_input = true },
        priority = 75,
    },

    -- Transform: reduce
    {
        id = "ts.transform.reduce",
        category = "transformation",
        language = "typescript",
        verb = { "reduce", "aggregate", "sum", "calculate" },
        template = [[return items.reduce((acc, item) => acc + item.${field}, 0);]],
        context_requirements = { has_array_input = true },
        priority = 70,
    },

    -- Convert to type
    {
        id = "ts.conversion.to",
        category = "conversion",
        language = "typescript",
        verb = { "to", "convert", "as" },
        template = [[return {
  id: this.id,
  // Map fields
} as ${entity}Dto;]],
        context_requirements = {},
        priority = 70,
    },

    -- Setter
    {
        id = "ts.setter",
        category = "accessor",
        language = "typescript",
        verb = { "set" },
        template = [[this.${field} = value;]],
        context_requirements = {},
        priority = 85,
    },

    -- Getter
    {
        id = "ts.getter",
        category = "accessor",
        language = "typescript",
        verb = { "get" },
        template = [[return this.${field};]],
        context_requirements = {},
        priority = 85,
    },

    -- React: handle change
    {
        id = "ts.react.handle_change",
        category = "event_handler",
        language = "typescript",
        verb = { "handle" },
        template = [[const { name, value } = event.target;
setState((prev) => ({ ...prev, [name]: value }));]],
        context_requirements = { is_react = true },
        priority = 75,
    },

    -- React: handle submit
    {
        id = "ts.react.handle_submit",
        category = "event_handler",
        language = "typescript",
        verb = { "handle" },
        template = [[event.preventDefault();
// Submit logic
await onSubmit(formData);]],
        context_requirements = { is_react = true },
        priority = 75,
    },
}

---Find templates matching criteria
---@param opts table {verb, language, category, qualifiers}
---@return table[] Matching templates sorted by priority
function M.find(opts)
    local matches = {}

    for _, template in ipairs(M.builtin) do
        if M._matches(template, opts) then
            table.insert(matches, template)
        end
    end

    -- Sort by priority (higher first)
    table.sort(matches, function(a, b)
        return a.priority > b.priority
    end)

    return matches
end

---Check if template matches criteria
---@param template table
---@param opts table
---@return boolean
function M._matches(template, opts)
    -- Language must match
    if opts.language and template.language ~= opts.language then
        return false
    end

    -- Verb must match
    if opts.verb then
        local template_verbs = type(template.verb) == "table" and template.verb or { template.verb }
        local verb_matches = false
        for _, v in ipairs(template_verbs) do
            if v == opts.verb then
                verb_matches = true
                break
            end
        end
        if not verb_matches then
            return false
        end
    end

    -- Category filter (optional)
    if opts.category and template.category ~= opts.category then
        return false
    end

    -- Qualifier filter (optional)
    if opts.qualifiers and template.qualifiers then
        local qual_matches = false
        for _, oq in ipairs(opts.qualifiers) do
            for _, tq in ipairs(template.qualifiers) do
                if oq == tq then
                    qual_matches = true
                    break
                end
            end
            if qual_matches then break end
        end
        if not qual_matches then
            return false
        end
    end

    return true
end

---Render a template with context
---@param template table Template definition
---@param context table Context variables
---@return string Rendered template
function M.render(template, context)
    local body = template.template

    -- Replace placeholders
    for key, value in pairs(context) do
        -- Only replace if value is a string (skip nil, tables, etc.)
        if type(value) == "string" then
            body = body:gsub("%${" .. key .. "}", value)
        elseif type(value) == "number" then
            body = body:gsub("%${" .. key .. "}", tostring(value))
        end
    end

    return body
end

---Build context from parsed semantic and LSP info
---@param semantic table Parsed semantic components
---@param lsp_context table|nil LSP-derived context
---@return table context
function M.build_context(semantic, lsp_context)
    local ctx = {}

    -- Entity from noun
    ctx.entity = semantic.noun or "Entity"
    ctx.entityVar = ctx.entity:sub(1, 1):lower() .. ctx.entity:sub(2)

    -- Field from qualifier or noun
    if #semantic.qualifiers > 0 then
        local q = semantic.qualifiers[1]
        ctx.qualifier = q.extracted or q.raw_part
        ctx.qualifierVar = ctx.qualifier:sub(1, 1):lower() .. ctx.qualifier:sub(2)
        ctx.field = ctx.qualifierVar
    else
        ctx.field = ctx.entityVar
    end

    -- Endpoint (lowercase plural)
    ctx.endpoint = ctx.entityVar:lower() .. "s"

    -- Default service/repository names
    ctx.repository = ctx.entityVar .. "Repository"
    ctx.service = ctx.entityVar .. "Service"
    ctx.mapper = ctx.entityVar .. "Mapper"

    -- Override with LSP context if available
    if lsp_context then
        if lsp_context.repository then
            ctx.repository = lsp_context.repository
            ctx.has_repository = true
        end
        if lsp_context.service then
            ctx.service = lsp_context.service
        end
        if lsp_context.mapper then
            ctx.mapper = lsp_context.mapper
            ctx.has_mapper = true
        end
    end

    -- Default param
    ctx.param = "id"

    return ctx
end

return M
