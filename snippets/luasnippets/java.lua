-- Dynamic Java/Spring Boot snippets with project context awareness
-- These snippets detect the actual package from your project structure
--
-- Usage: Type snippet prefix (e.g., spring_entity_ctx) and press Tab
-- The _ctx suffix indicates context-aware snippets that auto-detect packages

local ls = require("luasnip")

-- Get the directory of the current file
local snippet_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

-- List of snippet files to load
local snippet_files = {
    "java/entity.lua",
    "java/dto.lua",
    "java/controller.lua",
    "java/service.lua",
    "java/repository.lua",
    "java/exception.lua",
    "java/config.lua",
    "java/test.lua",
    "java/patterns.lua",
    "java/common.lua",
}

-- Load and register snippets from each file
for _, file in ipairs(snippet_files) do
    local filepath = snippet_dir .. "/" .. file
    if vim.fn.filereadable(filepath) == 1 then
        local ok, snippets = pcall(dofile, filepath)
        if ok and snippets then
            ls.add_snippets("java", snippets)
        else
            vim.notify("Failed to load snippet file: " .. file, vim.log.levels.WARN)
        end
    end
end

return {}
