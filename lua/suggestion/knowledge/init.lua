-- Knowledge Base Module
-- Manages templates (builtin + database-stored)
local M = {}

local templates = require("suggestion.knowledge.templates")

-- Re-export template functions
M.find = templates.find
M.render = templates.render
M.build_context = templates.build_context
M.builtin = templates.builtin

return M
