-- TypeScript/JavaScript treesitter queries for project indexer
local M = {}

-- Query for extracting variables
M.variable_query = [[
; Variable declarations (const, let, var)
(lexical_declaration
    (variable_declarator
        name: (identifier) @name
        type: (type_annotation (_) @type)?))

(variable_declaration
    (variable_declarator
        name: (identifier) @name
        type: (type_annotation (_) @type)?))

; Function parameters
(formal_parameters
    (required_parameter
        pattern: (identifier) @name
        type: (type_annotation (_) @type)?))

(formal_parameters
    (optional_parameter
        pattern: (identifier) @name
        type: (type_annotation (_) @type)?))

; Class properties
(public_field_definition
    name: (property_identifier) @name
    type: (type_annotation (_) @type)?)

(property_signature
    name: (property_identifier) @name
    type: (type_annotation (_) @type)?)

; Destructuring (object pattern)
(object_pattern
    (shorthand_property_identifier_pattern) @name)

; Destructuring (array pattern)
(array_pattern
    (identifier) @name)

; For-of/for-in loop variable
(for_in_statement
    left: (identifier) @name)

; Catch clause parameter
(catch_clause
    parameter: (identifier) @name)
]]

-- Query for extracting functions/methods
M.function_query = [[
; Function declarations
(function_declaration
    name: (identifier) @name
    parameters: (formal_parameters) @params
    return_type: (type_annotation (_) @return_type)?
    body: (statement_block) @body)

; Arrow functions assigned to variables
(lexical_declaration
    (variable_declarator
        name: (identifier) @name
        value: (arrow_function
            parameters: (formal_parameters) @params
            return_type: (type_annotation (_) @return_type)?
            body: (_) @body)))

; Method definitions in classes
(method_definition
    name: (property_identifier) @name
    parameters: (formal_parameters) @params
    return_type: (type_annotation (_) @return_type)?
    body: (statement_block) @body)

; Method signatures in interfaces
(method_signature
    name: (property_identifier) @name
    parameters: (formal_parameters) @params
    return_type: (type_annotation (_) @return_type)?)

; Function expressions assigned to variables
(lexical_declaration
    (variable_declarator
        name: (identifier) @name
        value: (function_expression
            parameters: (formal_parameters) @params
            return_type: (type_annotation (_) @return_type)?
            body: (statement_block) @body)))

; Object method shorthand
(object
    (method_definition
        name: (property_identifier) @name
        parameters: (formal_parameters) @params
        body: (statement_block) @body))
]]

-- Query for extracting class/interface information
M.class_query = [[
; Class declarations
(class_declaration
    name: (type_identifier) @name
    (class_heritage
        (extends_clause
            value: (identifier) @extends)?
        (implements_clause
            (type_identifier) @implements)*)?)

; Interface declarations
(interface_declaration
    name: (type_identifier) @name
    (extends_type_clause
        (type_identifier) @extends)*)

; Type alias declarations
(type_alias_declaration
    name: (type_identifier) @name)

; Enum declarations
(enum_declaration
    name: (identifier) @name)
]]

-- Query for extracting imports
M.import_query = [[
; Named imports
(import_statement
    (import_clause
        (named_imports
            (import_specifier
                name: (identifier) @name))))

; Default imports
(import_statement
    (import_clause
        (identifier) @name))

; Namespace imports
(import_statement
    (import_clause
        (namespace_import
            (identifier) @name)))
]]

-- Query for extracting exports
M.export_query = [[
; Named exports
(export_statement
    (export_clause
        (export_specifier
            name: (identifier) @name)))

; Default exports
(export_statement
    value: (identifier) @name)

; Export declarations
(export_statement
    declaration: (function_declaration
        name: (identifier) @name))

(export_statement
    declaration: (class_declaration
        name: (type_identifier) @name))
]]

-- Helper patterns for method name analysis (similar to Java)
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
    -- Boolean patterns
    is_check = {
        pattern = "^is(%u.*)$",
        suggestion_template = "return this.%s;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    has_check = {
        pattern = "^has(%u.*)$",
        suggestion_template = "return this.%s !== undefined;",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Async patterns
    fetch = {
        pattern = "^fetch(%u.*)$",
        suggestion_template = "const response = await fetch(url);\nreturn response.json();",
    },
    load = {
        pattern = "^load(%u.*)$",
        suggestion_template = "return await this.%sService.get();",
        transform = function(match)
            return match:sub(1, 1):lower() .. match:sub(2)
        end,
    },
    -- Handler patterns
    handle = {
        pattern = "^handle(%u.*)$",
        suggestion_template = "// Handle %s event",
    },
    on = {
        pattern = "^on(%u.*)$",
        suggestion_template = "// %s event handler",
    },
    -- Create/update patterns
    create = {
        pattern = "^create(%u.*)$",
        suggestion_template = "return { ...%s };",
    },
    update = {
        pattern = "^update(%u.*)$",
        suggestion_template = "return { ...%s, ...updates };",
    },
    delete = {
        pattern = "^delete(%u.*)$",
        suggestion_template = "return this.%sService.delete(id);",
    },
    -- Transform patterns
    map = {
        pattern = "^map(%u.*)$",
        suggestion_template = "return items.map(item => item);",
    },
    filter = {
        pattern = "^filter(%u.*)$",
        suggestion_template = "return items.filter(item => true);",
    },
    reduce = {
        pattern = "^reduce(%u.*)$",
        suggestion_template = "return items.reduce((acc, item) => acc, initial);",
    },
}

-- Common TypeScript types for inference
M.common_types = {
    "string",
    "number",
    "boolean",
    "void",
    "null",
    "undefined",
    "any",
    "unknown",
    "never",
    "object",
    "Array",
    "Promise",
    "Record",
    "Partial",
    "Required",
    "Pick",
    "Omit",
    "Map",
    "Set",
}

return M
