-- return {
-- 	require("plugins.default.treesitter"),
-- 	require("plugins.default.tree"),
-- 	require("plugins.default.bufferline"),
-- 	require("plugins.default.telescope"),
-- 	require("plugins.default.whichkey"),
-- 	require("plugins.default.lspconfig"),
-- 	require("plugins.default.lspkind"),
-- 	require("plugins.default.luasnip"),
-- 	require("plugins.default.nvim-cmp"),
-- 	require("plugins.default.lualine"),
-- 	require("plugins.default.noice"),
-- 	require("plugins.default.indent"),
-- 	require("plugins.default.gitsigns"),
-- 	require("plugins.default.autopairs"),
-- }

local function require_lua_plugins()
	local plugins = {}
	local plugin_dir = "plugins.default"

	for _, file in
		ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/" .. plugin_dir:gsub("%.", "/"), function(name)
			return name:match("%.lua$") and name ~= "init.lua"
		end))
	do
		local module_name = file:gsub("%.lua$", "")
		table.insert(plugins, require(plugin_dir .. "." .. module_name))
	end

	return plugins
end

return require_lua_plugins()
