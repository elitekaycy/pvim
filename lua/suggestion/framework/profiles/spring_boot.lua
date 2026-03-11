-- Spring Boot Profile
-- Conventions and enhancements for Spring Boot projects
local M = {}

M.id = "spring_boot"
M.name = "Spring Boot"
M.language = "java"

-- Spring Boot conventions
M.conventions = {
    -- Exception handling
    exception_not_found = "EntityNotFoundException",
    exception_validation = "MethodArgumentNotValidException",

    -- Optional handling
    optional_style = "orElseThrow",

    -- Collection style
    stream_collect = "toList",

    -- Logging
    logging = "slf4j",
    log_variable = "log",

    -- Dependency injection
    di_style = "constructor",  -- constructor, field
}

-- Template context additions for Spring Boot
M.context_defaults = {
    -- Use Lombok
    use_lombok = true,
    use_constructor_injection = true,
    use_field_annotations = false,

    -- Spring annotations
    annotations = {
        service = "@Service",
        repository = "@Repository",
        controller = "@RestController",
        component = "@Component",
        configuration = "@Configuration",
    },

    -- Common imports
    standard_imports = {
        "lombok.RequiredArgsConstructor",
        "lombok.extern.slf4j.Slf4j",
        "org.springframework.stereotype.Service",
        "org.springframework.stereotype.Repository",
        "org.springframework.web.bind.annotation.*",
        "org.springframework.transaction.annotation.Transactional",
    },

    -- JPA
    use_jpa = true,
    repository_suffix = "Repository",
    entity_suffix = "",
}

-- Template enhancements for Spring Boot
M.template_enhancements = {
    -- Add @Transactional to service methods
    transactional_methods = { "save", "update", "delete", "create" },

    -- Add @Slf4j logging
    add_logging = true,

    -- Use ResponseEntity for controllers
    use_response_entity = true,
}

---Apply profile to a template context
---@param context table Template context
---@return table Modified context
function M.apply(context)
    -- Merge defaults
    for k, v in pairs(M.context_defaults) do
        if context[k] == nil then
            context[k] = v
        end
    end

    context.framework = M.id
    context.framework_name = M.name

    -- Add Spring-specific context
    if context.class_type == "service" then
        context.class_annotation = "@Service"
        context.use_transactional = true
    elseif context.class_type == "repository" then
        context.class_annotation = "@Repository"
    elseif context.class_type == "controller" then
        context.class_annotation = "@RestController"
        context.use_response_entity = true
    end

    return context
end

---Modify generated code for Spring Boot
---@param code string Generated code
---@return string Modified code
function M.post_process(code)
    -- Add @Slf4j if logging is used
    if code:find("log%.") and not code:find("@Slf4j") then
        code = "@Slf4j\n" .. code
    end

    return code
end

---Get exception class for not found errors
---@return string
function M.get_not_found_exception()
    return "EntityNotFoundException"
end

---Get repository method pattern
---@param method_type string find, save, delete, exists
---@param qualifier string|nil Optional qualifier (ByEmail, ById, etc.)
---@return string Method pattern
function M.get_repository_method(method_type, qualifier)
    if method_type == "find" then
        if qualifier then
            return "findBy" .. qualifier
        else
            return "findById"
        end
    elseif method_type == "save" then
        return "save"
    elseif method_type == "delete" then
        return "deleteById"
    elseif method_type == "exists" then
        if qualifier then
            return "existsBy" .. qualifier
        else
            return "existsById"
        end
    end
    return method_type
end

return M
