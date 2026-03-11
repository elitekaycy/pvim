-- Java development tools plugin
-- Provides commands for generating Spring Boot modules

return {
    "nvim-lua/plenary.nvim", -- dependency for file operations
    ft = "java",
    config = function()
        local generator = require("util.java-generator")
        local project = require("util.java-project")

        -- Create user commands
        vim.api.nvim_create_user_command("SpringModule", function(opts)
            local entity = opts.args
            if entity == "" then
                generator.create_module_interactive()
            else
                -- Capitalize first letter
                entity = entity:sub(1, 1):upper() .. entity:sub(2)
                local results = generator.generate_module(entity)
                generator.print_results(results)

                -- Open entity file
                for _, item in ipairs(results.created) do
                    if item.type == "entity" then
                        vim.cmd("edit " .. item.path)
                        break
                    end
                end
            end
        end, {
            nargs = "?",
            desc = "Generate Spring Boot CRUD module (entity, dto, repo, mapper, service, controller)",
        })

        vim.api.nvim_create_user_command("SpringEntity", function(opts)
            local entity = opts.args
            if entity == "" then
                vim.ui.input({ prompt = "Entity name: " }, function(input)
                    if input and input ~= "" then
                        entity = input:sub(1, 1):upper() .. input:sub(2)
                        local path, err = generator.generate_file(entity, "entity", false)
                        if path then
                            print("Created: " .. path)
                            vim.cmd("edit " .. path)
                        else
                            print("Error: " .. (err or "unknown"))
                        end
                    end
                end)
            else
                entity = entity:sub(1, 1):upper() .. entity:sub(2)
                local path, err = generator.generate_file(entity, "entity", false)
                if path then
                    print("Created: " .. path)
                    vim.cmd("edit " .. path)
                else
                    print("Error: " .. (err or "unknown"))
                end
            end
        end, {
            nargs = "?",
            desc = "Generate Spring Boot entity",
        })

        vim.api.nvim_create_user_command("SpringBasic", function(opts)
            local entity = opts.args
            if entity == "" then
                vim.ui.input({ prompt = "Entity name: " }, function(input)
                    if input and input ~= "" then
                        entity = input:sub(1, 1):upper() .. input:sub(2)
                        local results = generator.generate_basic(entity)
                        generator.print_results(results)
                    end
                end)
            else
                entity = entity:sub(1, 1):upper() .. entity:sub(2)
                local results = generator.generate_basic(entity)
                generator.print_results(results)
            end
        end, {
            nargs = "?",
            desc = "Generate basic Spring Boot module (entity, dto, repository)",
        })

        vim.api.nvim_create_user_command("SpringProject", function()
            project.debug()
        end, {
            desc = "Show Spring Boot project structure",
        })

        vim.api.nvim_create_user_command("SpringList", function()
            local entities = project.list_entities()
            if #entities == 0 then
                print("No entities found")
            else
                print("Entities in project:")
                for _, entity in ipairs(entities) do
                    local files = project.check_entity_files(entity)
                    local status = {}
                    for file_type, exists in pairs(files) do
                        if exists then
                            table.insert(status, file_type)
                        end
                    end
                    print("  " .. entity .. ": " .. table.concat(status, ", "))
                end
            end
        end, {
            desc = "List existing entities and their files",
        })

        vim.api.nvim_create_user_command("SpringComplete", function(opts)
            local entity = opts.args
            if entity == "" then
                -- Show picker with existing entities
                local entities = project.list_entities()
                if #entities == 0 then
                    print("No entities found")
                    return
                end

                vim.ui.select(entities, { prompt = "Select entity to complete:" }, function(selected)
                    if selected then
                        local files = project.check_entity_files(selected)
                        local missing = {}
                        for file_type, exists in pairs(files) do
                            if not exists then
                                table.insert(missing, file_type)
                            end
                        end

                        if #missing == 0 then
                            print(selected .. " is complete!")
                        else
                            print("Creating missing files for " .. selected .. ": " .. table.concat(missing, ", "))
                            local results = generator.generate_module(selected)
                            generator.print_results(results)
                        end
                    end
                end)
            else
                entity = entity:sub(1, 1):upper() .. entity:sub(2)
                local results = generator.generate_module(entity)
                generator.print_results(results)
            end
        end, {
            nargs = "?",
            desc = "Complete missing files for an entity",
        })

        -- Keymaps (optional, only in Java files)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                local opts = { buffer = true, silent = true }
                vim.keymap.set("n", "<leader>jm", ":SpringModule ", vim.tbl_extend("force", opts, { desc = "Generate Spring module" }))
                vim.keymap.set("n", "<leader>je", ":SpringEntity ", vim.tbl_extend("force", opts, { desc = "Generate Spring entity" }))
                vim.keymap.set("n", "<leader>jp", ":SpringProject<CR>", vim.tbl_extend("force", opts, { desc = "Show project structure" }))
                vim.keymap.set("n", "<leader>jl", ":SpringList<CR>", vim.tbl_extend("force", opts, { desc = "List entities" }))
                vim.keymap.set("n", "<leader>jc", ":SpringComplete<CR>", vim.tbl_extend("force", opts, { desc = "Complete entity files" }))
            end,
        })
    end,
}
