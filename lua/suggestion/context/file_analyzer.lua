-- File Context Analyzer
-- Deep analysis of current file to understand class type, fields, imports, etc.
local M = {}

---@class FileContext
---@field class_type string Type of class (service, controller, repository, etc.)
---@field class_name string Name of the class
---@field package string Package/namespace
---@field annotations string[] Class-level annotations
---@field fields FieldInfo[] Class fields
---@field methods string[] Method names in the class
---@field imports table<string, string> Import map (simple name -> full path)
---@field implements string[] Implemented interfaces
---@field extends string|nil Parent class

---@class FieldInfo
---@field name string Field name
---@field type string Field type
---@field injected boolean Whether field is dependency injected
---@field static boolean Whether field is static

-- Class type detection by annotation (priority 1)
local ANNOTATION_CLASS_TYPES = {
    -- Spring
    ["@RestController"] = "controller",
    ["@Controller"] = "controller",
    ["@Service"] = "service",
    ["@Repository"] = "repository",
    ["@Entity"] = "entity",
    ["@Configuration"] = "config",
    ["@Component"] = "component",
    -- JPA
    ["@Table"] = "entity",
    -- Jakarta/Java EE
    ["@Stateless"] = "service",
    ["@Stateful"] = "service",
    ["@Singleton"] = "service",
    ["@ManagedBean"] = "component",
}

-- Class type detection by naming convention (priority 2)
local NAME_SUFFIX_CLASS_TYPES = {
    { suffix = "Controller", type = "controller" },
    { suffix = "RestController", type = "controller" },
    { suffix = "Service", type = "service" },
    { suffix = "ServiceImpl", type = "service" },
    { suffix = "Repository", type = "repository" },
    { suffix = "Dao", type = "repository" },
    { suffix = "DAO", type = "repository" },
    { suffix = "Entity", type = "entity" },
    { suffix = "Model", type = "model" },
    { suffix = "Dto", type = "dto" },
    { suffix = "DTO", type = "dto" },
    { suffix = "Request", type = "dto" },
    { suffix = "Response", type = "dto" },
    { suffix = "Mapper", type = "mapper" },
    { suffix = "Converter", type = "converter" },
    { suffix = "Utils", type = "utility" },
    { suffix = "Util", type = "utility" },
    { suffix = "Helper", type = "utility" },
    { suffix = "Exception", type = "exception" },
    { suffix = "Config", type = "config" },
    { suffix = "Configuration", type = "config" },
    { suffix = "Test", type = "test" },
    { suffix = "Tests", type = "test" },
    { suffix = "Spec", type = "test" },
    { suffix = "Factory", type = "factory" },
    { suffix = "Builder", type = "builder" },
}

-- Injection annotations
local INJECTION_ANNOTATIONS = {
    "@Autowired", "@Inject", "@Resource", "@Value",
}

---Detect class type from annotations
---@param annotations string[]
---@return string|nil
local function detect_type_from_annotations(annotations)
    for _, annotation in ipairs(annotations) do
        local base_annotation = annotation:match("^(@%w+)")
        if base_annotation and ANNOTATION_CLASS_TYPES[base_annotation] then
            return ANNOTATION_CLASS_TYPES[base_annotation]
        end
    end
    return nil
end

---Detect class type from name suffix
---@param class_name string
---@return string
local function detect_type_from_name(class_name)
    for _, mapping in ipairs(NAME_SUFFIX_CLASS_TYPES) do
        if class_name:match(mapping.suffix .. "$") then
            return mapping.type
        end
    end
    return "class"
end

---Check if a field is dependency injected
---@param field_annotations string[]
---@return boolean
local function is_field_injected(field_annotations)
    for _, annotation in ipairs(field_annotations) do
        for _, inject_annotation in ipairs(INJECTION_ANNOTATIONS) do
            if annotation:find(inject_annotation, 1, true) then
                return true
            end
        end
    end
    return false
end

---Parse Java file using treesitter
---@param bufnr number Buffer number
---@return FileContext|nil
function M.analyze_java(bufnr)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "java")
    if not ok or not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil
    end

    local root = tree:root()
    local context = {
        class_type = "class",
        class_name = "",
        package = "",
        annotations = {},
        fields = {},
        methods = {},
        imports = {},
        implements = {},
        extends = nil,
    }

    -- Query for package declaration
    local package_query = vim.treesitter.query.parse("java", [[
        (package_declaration (scoped_identifier) @package)
    ]])

    for _, node in package_query:iter_captures(root, bufnr) do
        context.package = vim.treesitter.get_node_text(node, bufnr)
    end

    -- Query for imports
    local import_query = vim.treesitter.query.parse("java", [[
        (import_declaration (scoped_identifier) @import)
    ]])

    for _, node in import_query:iter_captures(root, bufnr) do
        local full_import = vim.treesitter.get_node_text(node, bufnr)
        local simple_name = full_import:match("%.([^%.]+)$") or full_import
        context.imports[simple_name] = full_import
    end

    -- Query for class declaration
    local class_query = vim.treesitter.query.parse("java", [[
        (class_declaration
            (modifiers (marker_annotation)? @annotation)*
            name: (identifier) @class_name
            (superclass (type_identifier) @extends)?
            (super_interfaces (type_list (type_identifier) @implements))?)
    ]])

    local class_annotations = {}
    for id, node in class_query:iter_captures(root, bufnr) do
        local name = class_query.captures[id]
        local text = vim.treesitter.get_node_text(node, bufnr)

        if name == "annotation" then
            table.insert(class_annotations, text)
        elseif name == "class_name" then
            context.class_name = text
        elseif name == "extends" then
            context.extends = text
        elseif name == "implements" then
            table.insert(context.implements, text)
        end
    end
    context.annotations = class_annotations

    -- Query for fields
    local field_query = vim.treesitter.query.parse("java", [[
        (field_declaration
            (modifiers
                (marker_annotation)? @field_annotation
                (annotation)? @field_annotation2
                "static"? @static
                "final"? @final)?
            type: (_) @field_type
            declarator: (variable_declarator
                name: (identifier) @field_name))
    ]])

    local current_field = {}
    local field_annotations = {}

    for id, node in field_query:iter_captures(root, bufnr) do
        local name = field_query.captures[id]
        local text = vim.treesitter.get_node_text(node, bufnr)

        if name == "field_annotation" or name == "field_annotation2" then
            table.insert(field_annotations, text)
        elseif name == "static" then
            current_field.static = true
        elseif name == "field_type" then
            current_field.type = text
        elseif name == "field_name" then
            current_field.name = text
            current_field.injected = is_field_injected(field_annotations)
            current_field.static = current_field.static or false
            table.insert(context.fields, current_field)
            current_field = {}
            field_annotations = {}
        end
    end

    -- Query for methods
    local method_query = vim.treesitter.query.parse("java", [[
        (method_declaration
            name: (identifier) @method_name)
    ]])

    for _, node in method_query:iter_captures(root, bufnr) do
        local method_name = vim.treesitter.get_node_text(node, bufnr)
        table.insert(context.methods, method_name)
    end

    -- Determine class type
    context.class_type = detect_type_from_annotations(context.annotations)
        or detect_type_from_name(context.class_name)

    return context
end

---Parse TypeScript file using treesitter
---@param bufnr number Buffer number
---@return FileContext|nil
function M.analyze_typescript(bufnr)
    local ft = vim.bo[bufnr].filetype
    local lang = (ft == "typescriptreact" or ft == "javascriptreact") and "tsx" or "typescript"

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
    if not ok or not parser then
        return nil
    end

    local tree = parser:parse()[1]
    if not tree then
        return nil
    end

    local root = tree:root()
    local context = {
        class_type = "module",
        class_name = "",
        package = "",
        annotations = {},
        fields = {},
        methods = {},
        imports = {},
        implements = {},
        extends = nil,
    }

    -- Get filename for class type detection
    local filename = vim.fn.expand("%:t:r")
    context.class_name = filename

    -- Detect from filepath
    local filepath = vim.fn.expand("%:p")
    if filepath:match("/controllers/") or filepath:match("%.controller%.") then
        context.class_type = "controller"
    elseif filepath:match("/services/") or filepath:match("%.service%.") then
        context.class_type = "service"
    elseif filepath:match("/components/") or filepath:match("%.component%.") then
        context.class_type = "component"
    elseif filepath:match("/utils/") or filepath:match("%.util%.") then
        context.class_type = "utility"
    elseif filepath:match("/hooks/") or filepath:match("%.hook%.") then
        context.class_type = "hook"
    end

    -- Query for imports
    local import_query_str = [[
        (import_statement
            (import_clause
                (named_imports
                    (import_specifier
                        name: (identifier) @import_name)))
            source: (string) @import_source)
    ]]

    local import_ok, import_query = pcall(vim.treesitter.query.parse, lang, import_query_str)
    if import_ok then
        for id, node in import_query:iter_captures(root, bufnr) do
            local name = import_query.captures[id]
            local text = vim.treesitter.get_node_text(node, bufnr)

            if name == "import_name" then
                context.imports[text] = text
            end
        end
    end

    -- Query for class properties
    local property_query_str = [[
        (class_declaration
            name: (type_identifier) @class_name
            (class_heritage
                (extends_clause (identifier) @extends)?
                (implements_clause (type_identifier) @implements)?)?
            body: (class_body
                (public_field_definition
                    name: (property_identifier) @field_name
                    type: (type_annotation)? @field_type)?
                (method_definition
                    name: (property_identifier) @method_name)?))
    ]]

    local prop_ok, property_query = pcall(vim.treesitter.query.parse, lang, property_query_str)
    if prop_ok then
        for id, node in property_query:iter_captures(root, bufnr) do
            local name = property_query.captures[id]
            local text = vim.treesitter.get_node_text(node, bufnr)

            if name == "class_name" then
                context.class_name = text
            elseif name == "extends" then
                context.extends = text
            elseif name == "implements" then
                table.insert(context.implements, text)
            elseif name == "field_name" then
                table.insert(context.fields, {
                    name = text,
                    type = "",
                    injected = false,
                    static = false,
                })
            elseif name == "method_name" then
                table.insert(context.methods, text)
            end
        end
    end

    -- Check for React component (function returning JSX)
    if ft == "typescriptreact" or ft == "javascriptreact" then
        local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
        if content:match("return%s*%(?%s*<") or content:match("=>%s*%(?%s*<") then
            context.class_type = "react_component"
        end
    end

    return context
end

---Analyze current buffer and return file context
---@param bufnr number|nil Buffer number (default: current buffer)
---@return FileContext|nil
function M.analyze(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype

    if ft == "java" then
        return M.analyze_java(bufnr)
    elseif ft == "typescript" or ft == "typescriptreact"
        or ft == "javascript" or ft == "javascriptreact" then
        return M.analyze_typescript(bufnr)
    end

    return nil
end

---Get a field by type pattern
---@param context FileContext
---@param type_pattern string Pattern to match field type
---@return FieldInfo|nil
function M.find_field_by_type(context, type_pattern)
    for _, field in ipairs(context.fields) do
        if field.type:match(type_pattern) then
            return field
        end
    end
    return nil
end

---Get all injected dependencies
---@param context FileContext
---@return FieldInfo[]
function M.get_dependencies(context)
    local deps = {}
    for _, field in ipairs(context.fields) do
        if field.injected then
            table.insert(deps, field)
        end
    end
    return deps
end

---Check if class has a specific method
---@param context FileContext
---@param method_name string
---@return boolean
function M.has_method(context, method_name)
    for _, m in ipairs(context.methods) do
        if m == method_name then
            return true
        end
    end
    return false
end

---Infer entity name from class context
---@param context FileContext
---@return string|nil
function M.infer_entity(context)
    -- Try from class name (UserService -> User)
    local entity = context.class_name:match("^(%u%l+)")
    if entity then
        return entity
    end

    -- Try from repository field type (UserRepository -> User)
    for _, field in ipairs(context.fields) do
        if field.type:match("Repository") then
            entity = field.type:match("^(%u%l+)")
            if entity then
                return entity
            end
        end
    end

    return nil
end

return M
