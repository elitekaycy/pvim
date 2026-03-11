-- Java treesitter queries for project indexer
local M = {}

-- Query for extracting variables (fields, locals, parameters)
M.variable_query = [[
; Field declarations
(field_declaration
    type: (_) @type
    declarator: (variable_declarator
        name: (identifier) @name)) @scope
(#set! scope "field")

; Local variable declarations
(local_variable_declaration
    type: (_) @type
    declarator: (variable_declarator
        name: (identifier) @name)) @scope
(#set! scope "local")

; Method parameters
(formal_parameter
    type: (_) @type
    name: (identifier) @name) @scope
(#set! scope "param")

; Enhanced for loop variable
(enhanced_for_statement
    type: (_) @type
    name: (identifier) @name) @scope
(#set! scope "local")

; Catch clause parameter
(catch_formal_parameter
    type: (_) @type
    name: (identifier) @name) @scope
(#set! scope "local")

; Resource in try-with-resources
(resource
    type: (_) @type
    name: (identifier) @name) @scope
(#set! scope "local")
]]

-- Query for extracting methods/functions
M.function_query = [[
; Method declarations
(method_declaration
    type: (_) @return_type
    name: (identifier) @name
    parameters: (formal_parameters) @params
    body: (block)? @body)

; Constructor declarations
(constructor_declaration
    name: (identifier) @name
    parameters: (formal_parameters) @params
    body: (constructor_body) @body)
]]

-- Query for extracting class/interface information
M.class_query = [[
; Class declarations
(class_declaration
    name: (identifier) @name
    superclass: (superclass (type_identifier) @extends)?
    interfaces: (super_interfaces (type_list (type_identifier) @implements)*)?)

; Interface declarations
(interface_declaration
    name: (identifier) @name
    (extends_interfaces (type_list (type_identifier) @extends)*)?)

; Enum declarations
(enum_declaration
    name: (identifier) @name)

; Record declarations (Java 14+)
(record_declaration
    name: (identifier) @name)
]]

-- Query for extracting imports
M.import_query = [[
(import_declaration
    (scoped_identifier) @import)

(import_declaration
    (identifier) @import)
]]

-- Query for extracting annotations
M.annotation_query = [[
(annotation
    name: (identifier) @name)

(marker_annotation
    name: (identifier) @name)
]]

-- Helper patterns for method name analysis
M.method_patterns = {
    -- Getter patterns
    getter = {
        pattern = "^get(%u.*)$",
        suggestion_template = "return this.%s;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Setter patterns
    setter = {
        pattern = "^set(%u.*)$",
        suggestion_template = "this.%s = %s;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Boolean getter patterns
    is_getter = {
        pattern = "^is(%u.*)$",
        suggestion_template = "return this.%s;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    has_getter = {
        pattern = "^has(%u.*)$",
        suggestion_template = "return this.%s;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Calculator patterns
    calculate = {
        pattern = "^calculate(%u.*)$",
        keywords = { "sum", "total", "average", "count", "result" },
    },
    -- Builder patterns
    with = {
        pattern = "^with(%u.*)$",
        suggestion_template = "this.%s = %s;\nreturn this;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Factory patterns
    create = {
        pattern = "^create(%u.*)$",
        suggestion_template = "return new %s();",
    },
    of = {
        pattern = "^of$",
        suggestion_template = "return new %s(%s);",
    },
    -- Validation patterns
    validate = {
        pattern = "^validate(%u.*)$",
        keywords = { "valid", "invalid", "error", "check" },
    },
    -- Conversion patterns
    to = {
        pattern = "^to(%u.*)$",
        suggestion_template = "return new %s(this);",
    },
    from = {
        pattern = "^from(%u.*)$",
        suggestion_template = "return new %s(%s);",
    },
}

-- Common Java types for inference
M.common_types = {
    "String",
    "Integer",
    "int",
    "Long",
    "long",
    "Boolean",
    "boolean",
    "Double",
    "double",
    "Float",
    "float",
    "List",
    "ArrayList",
    "Map",
    "HashMap",
    "Set",
    "HashSet",
    "Optional",
    "void",
}

return M
