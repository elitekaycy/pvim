local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function ftl_code_actions()
    local ftl_actions = {
        { label = "Insert IF statement",       action = "FTLIf" },
        { label = "Insert List statement",     action = "FTLList" },
        { label = "Insert Big List statement", action = "FTLBigList" },
        { label = "Insert Switch statement",   action = "FTLSwitch" },
        { label = "Insert Assign statement",   action = "FTLAssign" },
    }

    pickers.new({}, {
        prompt_title = "FTL Code Actions",
        finder = finders.new_table({
            results = ftl_actions,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.label,
                    ordinal = entry.label,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if not selection then
                    return
                end

                actions.close(prompt_bufnr)

                if selection.value and selection.value.action then
                    vim.cmd("call " .. selection.value.action .. "()")
                end
            end)

            return true
        end,
    }):find()
end

return {
    ftl_code_actions = ftl_code_actions
}
