-- Semantic Analysis Module
-- Coordinates semantic parsing and analysis
local M = {}

local parser = require("suggestion.semantic.parser")

-- Re-export parser functions
M.parse = parser.parse
M.split_camel_case = parser.split_camel_case
M.classify_verb = parser.classify_verb
M.is_plural = parser.is_plural
M.singularize = parser.singularize
M.to_variable_name = parser.to_variable_name
M.get_expected_patterns = parser.get_expected_patterns
M.expects_return = parser.expects_return
M.suggested_return_type = parser.suggested_return_type

-- Export taxonomy for external use
M.verb_taxonomy = parser.verb_taxonomy
M.qualifier_patterns = parser.qualifier_patterns

return M
