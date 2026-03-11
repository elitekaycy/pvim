-- Java development tools plugin
-- Provides commands for generating Spring Boot modules

return {
    "nvim-lua/plenary.nvim", -- dependency for file operations
    ft = "java",
    config = function()
        local generator = require("util.java-generator")
        local project = require("util.java-project")

        -- Completion function for entity names
        local function complete_entities(arg_lead, cmd_line, cursor_pos)
            local entities = project.list_entities()
            local matches = {}
            for _, entity in ipairs(entities) do
                if entity:lower():find(arg_lead:lower(), 1, true) then
                    table.insert(matches, entity)
                end
            end
            return matches
        end

        -- Completion for new entity names (suggests based on common patterns)
        local function complete_new_entity(arg_lead, cmd_line, cursor_pos)
            local suggestions = {
                "User", "Product", "Order", "Customer", "Category",
                "Item", "Payment", "Invoice", "Account", "Profile",
                "Comment", "Post", "Article", "Tag", "Role",
            }
            local matches = {}
            for _, name in ipairs(suggestions) do
                if name:lower():find(arg_lead:lower(), 1, true) then
                    table.insert(matches, name)
                end
            end
            -- Also add existing entities
            for _, entity in ipairs(project.list_entities()) do
                if entity:lower():find(arg_lead:lower(), 1, true) then
                    table.insert(matches, entity)
                end
            end
            return matches
        end

        -- :SpringModule [Entity] - Generate full CRUD module
        vim.api.nvim_create_user_command("SpringModule", function(opts)
            local entity = opts.args
            if entity == "" then
                generator.create_module_interactive()
            else
                entity = entity:sub(1, 1):upper() .. entity:sub(2)
                local results = generator.generate_module(entity)
                generator.print_results(results)

                for _, item in ipairs(results.created) do
                    if item.type == "entity" then
                        vim.cmd("edit " .. item.path)
                        break
                    end
                end
            end
        end, {
            nargs = "?",
            complete = complete_new_entity,
            desc = "Generate Spring Boot CRUD module (entity, dto, repo, mapper, service, controller)",
        })

        -- :SpringEntity [Entity] - Generate just entity
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
            complete = complete_new_entity,
            desc = "Generate Spring Boot entity",
        })

        -- :SpringDto [Entity] - Generate DTO
        vim.api.nvim_create_user_command("SpringDto", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "dto", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot DTO",
        })

        -- :SpringRepository [Entity] - Generate Repository
        vim.api.nvim_create_user_command("SpringRepository", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "repository", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot Repository",
        })

        -- :SpringService [Entity] - Generate Service
        vim.api.nvim_create_user_command("SpringService", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "service", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot Service",
        })

        -- :SpringController [Entity] - Generate Controller
        vim.api.nvim_create_user_command("SpringController", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "controller", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot Controller",
        })

        -- :SpringMapper [Entity] - Generate Mapper
        vim.api.nvim_create_user_command("SpringMapper", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "mapper", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot Mapper",
        })

        -- :SpringBasic [Entity] - Generate entity + dto + repository
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
            complete = complete_new_entity,
            desc = "Generate basic Spring Boot module (entity, dto, repository)",
        })

        -- :SpringProject - Show project structure
        vim.api.nvim_create_user_command("SpringProject", function()
            project.debug()
        end, {
            desc = "Show Spring Boot project structure",
        })

        -- :SpringList - List entities
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

        -- :SpringComplete [Entity] - Complete missing files
        vim.api.nvim_create_user_command("SpringComplete", function(opts)
            local entity = opts.args
            if entity == "" then
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
            complete = complete_entities,
            desc = "Complete missing files for an entity",
        })

        -- :SpringTest [Entity] - Generate test for entity
        vim.api.nvim_create_user_command("SpringTest", function(opts)
            local entity = opts.args
            if entity == "" then return end
            entity = entity:sub(1, 1):upper() .. entity:sub(2)
            local path, err = generator.generate_file(entity, "test_service", false)
            if path then
                print("Created: " .. path)
                vim.cmd("edit " .. path)
            else
                print("Error: " .. (err or "unknown"))
            end
        end, {
            nargs = 1,
            complete = complete_entities,
            desc = "Generate Spring Boot Service Test",
        })

        -- :SpringGoto [type] - Jump to file for current entity context
        vim.api.nvim_create_user_command("SpringGoto", function(opts)
            local target = opts.args
            local ctx = require("util.java-context")
            local entity = ctx.get_class_name()

            -- Extract entity name from current class
            local suffixes = { "Controller", "Service", "Repository", "Mapper", "Dto", "DTO", "Test" }
            for _, suffix in ipairs(suffixes) do
                if entity:sub(-#suffix) == suffix then
                    entity = entity:sub(1, -#suffix - 1)
                    break
                end
            end

            local structure = project.get_structure()
            if not structure then
                print("No project structure found")
                return
            end

            local base_path = structure.src_main .. "/" .. structure.base_package:gsub("%.", "/")
            local file_map = {
                entity = base_path .. "/entity/" .. entity .. ".java",
                dto = base_path .. "/dto/" .. entity .. "Dto.java",
                repository = base_path .. "/repository/" .. entity .. "Repository.java",
                mapper = base_path .. "/mapper/" .. entity .. "Mapper.java",
                service = base_path .. "/service/" .. entity .. "Service.java",
                controller = base_path .. "/controller/" .. entity .. "Controller.java",
                test = structure.src_test .. "/" .. structure.base_package:gsub("%.", "/") .. "/service/" .. entity .. "ServiceTest.java",
            }

            local file_path = file_map[target]
            if file_path and vim.fn.filereadable(file_path) == 1 then
                vim.cmd("edit " .. file_path)
            else
                print("File not found: " .. (file_path or target))
            end
        end, {
            nargs = 1,
            complete = function()
                return { "entity", "dto", "repository", "mapper", "service", "controller", "test" }
            end,
            desc = "Jump to related file for current entity",
        })

        -- Keymaps (in Java files)
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = function()
                local opts = { buffer = true, silent = true }
                vim.keymap.set("n", "<leader>jm", ":SpringModule ", vim.tbl_extend("force", opts, { desc = "Spring: Generate module" }))
                vim.keymap.set("n", "<leader>je", ":SpringEntity ", vim.tbl_extend("force", opts, { desc = "Spring: Generate entity" }))
                vim.keymap.set("n", "<leader>jp", ":SpringProject<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Show project" }))
                vim.keymap.set("n", "<leader>jl", ":SpringList<CR>", vim.tbl_extend("force", opts, { desc = "Spring: List entities" }))
                vim.keymap.set("n", "<leader>jc", ":SpringComplete<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Complete entity" }))

                -- Quick goto keymaps
                vim.keymap.set("n", "<leader>jge", ":SpringGoto entity<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto entity" }))
                vim.keymap.set("n", "<leader>jgd", ":SpringGoto dto<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto dto" }))
                vim.keymap.set("n", "<leader>jgr", ":SpringGoto repository<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto repository" }))
                vim.keymap.set("n", "<leader>jgs", ":SpringGoto service<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto service" }))
                vim.keymap.set("n", "<leader>jgc", ":SpringGoto controller<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto controller" }))
                vim.keymap.set("n", "<leader>jgm", ":SpringGoto mapper<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto mapper" }))
                vim.keymap.set("n", "<leader>jgt", ":SpringGoto test<CR>", vim.tbl_extend("force", opts, { desc = "Spring: Goto test" }))
            end,
        })
    end,
}
