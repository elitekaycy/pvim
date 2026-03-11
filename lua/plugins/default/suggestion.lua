-- Context-Aware Code Suggestion System
-- Provides intelligent code suggestions based on semantic analysis, LSP, and project patterns
-- Includes ghost text (Copilot-style) inline suggestions
return {
    dir = vim.fn.stdpath("config") .. "/lua/suggestion",
    name = "pvim-suggestion",
    dependencies = {
        "pvim-indexer",
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
    },
    ft = { "java", "typescript", "typescriptreact", "javascript", "javascriptreact" },
    cmd = {
        "SuggestToggle", "SuggestStatus", "SuggestParse", "SuggestTest",
        "GhostToggle", "GhostTrigger", "GhostStatus", "GhostTest", "GhostDebug",
        "AIInit", "AIStatus", "AIDebug", "AIToggle", "AITest", "AIContext", "AIClearCache", "AIModel",
        "ContextAnalyze", "FrameworkDetect",
    },
    config = function()
        -- Master control - disabled by default, enable with :SuggestToggle
        local master = require("suggestion.master")

        local suggestion = require("suggestion")

        suggestion.setup({
            enabled = true,
            languages = { "java", "typescript", "javascript" },
            max_suggestions = 5,
            min_score = 25,
            weights = {
                semantic = 0.25,
                template = 0.25,
                lsp_context = 0.20,
                convention = 0.15,
                similarity = 0.15,
            },
        })

        -- Setup ghost text (Copilot-style inline suggestions)
        local ghost_ok, ghost = pcall(require, "suggestion.ghost")
        if ghost_ok then
            ghost.setup({
                enabled = master.is_enabled(),  -- Respect master toggle
                debounce_ms = 500,  -- Wait 500ms after typing stops (prevents lag)
                triggers = {
                    "method_body", "statement", "expression", "class_scaffold",
                    "line", "assignment", "return", "method_call",
                },
                min_score = 15,
            })
        end

        -- Setup AI (Claude integration) - optimized for minimal tokens
        local ai_ok, ai = pcall(require, "suggestion.ai")
        if ai_ok then
            ai.setup({
                enabled = master.is_enabled(),  -- Respect master toggle
                model = "claude-3-5-haiku-20241022",  -- Fast/cheap
                enhance_always = false,
                fallback_threshold = 40,
            })
        end

        -- Master toggle command
        vim.api.nvim_create_user_command("SuggestToggle", function()
            local enabled = master.toggle()
            print("Suggestion System: " .. (enabled and "ON" or "OFF"))
        end, { desc = "Toggle entire suggestion system (indexing, AI, ghost text)" })

        -- User commands
        vim.api.nvim_create_user_command("SuggestStatus", function()
            local master_status = master.status()
            local status = suggestion.status()
            print(string.format(
                "Suggestion System: MASTER=%s | core=%s, initialized=%s",
                master_status.enabled and "ON" or "OFF",
                tostring(status.enabled),
                tostring(status.initialized)
            ))
            if master_status.enabled then
                print("  Languages: " .. table.concat(status.languages, ", "))
                print("  Use :SuggestToggle to disable")
            else
                print("  Use :SuggestToggle to enable")
            end
        end, { desc = "Show suggestion system status" })

        vim.api.nvim_create_user_command("SuggestParse", function(opts)
            local method_name = opts.args
            if method_name == "" then
                print("Usage: :SuggestParse <method_name>")
                return
            end

            local parsed = suggestion.parse(method_name)
            print("Parsed method: " .. method_name)
            print("  Verb: " .. (parsed.verb or "nil") .. " (" .. (parsed.verb_category or "unclassified") .. ")")
            print("  Noun: " .. (parsed.noun or "nil") .. (parsed.noun_plural and " (plural)" or ""))
            if #parsed.qualifiers > 0 then
                print("  Qualifiers:")
                for _, q in ipairs(parsed.qualifiers) do
                    print("    - " .. q.text .. " (" .. (q.type or "unknown") .. ")")
                end
            end
        end, { nargs = 1, desc = "Parse a method name semantically" })

        vim.api.nvim_create_user_command("SuggestTest", function(opts)
            local method_name = opts.args
            if method_name == "" then
                print("Usage: :SuggestTest <method_name>")
                return
            end

            local suggestions = suggestion.get_suggestions(method_name, nil, nil)
            if #suggestions == 0 then
                print("No suggestions for: " .. method_name)
                return
            end

            print("Suggestions for: " .. method_name)
            for i, s in ipairs(suggestions) do
                print(string.format("%d. [%s %.0f%%] %s",
                    i,
                    s.source,
                    s.score,
                    s.template_id or "heuristic"
                ))
                -- Print first line of body
                local first_line = s.body:match("^([^\n]+)")
                print("   " .. (first_line or s.body))
            end
        end, { nargs = 1, desc = "Test suggestions for a method name" })

        -- Ghost text commands
        vim.api.nvim_create_user_command("GhostToggle", function()
            if ghost_ok then
                ghost.toggle()
                local status = ghost.status()
                print("Ghost text: " .. (status.enabled and "enabled" or "disabled"))
            else
                print("Ghost text module not loaded")
            end
        end, { desc = "Toggle ghost text suggestions" })

        vim.api.nvim_create_user_command("GhostTrigger", function()
            if ghost_ok then
                ghost.trigger()
            else
                print("Ghost text module not loaded")
            end
        end, { desc = "Manually trigger ghost text suggestions" })

        -- Test command to verify ghost text rendering works
        vim.api.nvim_create_user_command("GhostTest", function()
            local renderer = require("suggestion.ghost.renderer")
            renderer.show("// This is a test ghost suggestion\n// If you see this in gray, ghost text works!", 0)
            print("Ghost test shown - you should see gray text at cursor. Press Esc to clear.")
        end, { desc = "Test ghost text rendering" })

        -- Debug command to see what triggers are detected
        vim.api.nvim_create_user_command("GhostDebug", function()
            local master_status = master.status()
            print("Master: " .. (master_status.enabled and "ON" or "OFF"))

            if ghost_ok then
                local status = ghost.status()
                print("Ghost: enabled=" .. tostring(status.enabled) .. ", initialized=" .. tostring(status.initialized))
            end

            if ai_ok then
                local status = ai.status()
                print("AI: enabled=" .. tostring(status.enabled) .. ", ready=" .. tostring(status.client_ready))
            end

            -- Check trigger
            local triggers_mod = require("suggestion.ghost.triggers")
            local trigger = triggers_mod.detect(0)
            if trigger then
                print("Trigger detected: " .. trigger.type)
                if trigger.method_name then
                    print("  Method: " .. trigger.method_name)
                end
                if trigger.context then
                    for k, v in pairs(trigger.context) do
                        if type(v) == "string" then
                            print("  " .. k .. ": " .. v)
                        end
                    end
                end
            else
                print("No trigger detected at cursor")
            end
        end, { desc = "Debug ghost text system" })

        vim.api.nvim_create_user_command("GhostStatus", function()
            if ghost_ok then
                local status = ghost.status()
                print(string.format(
                    "Ghost Text: enabled=%s, visible=%s, suggestions=%d",
                    tostring(status.enabled),
                    tostring(status.visible),
                    status.suggestion_count
                ))
            else
                print("Ghost text module not loaded")
            end
        end, { desc = "Show ghost text status" })

        -- Context analysis command
        vim.api.nvim_create_user_command("ContextAnalyze", function()
            local context_ok, context = pcall(require, "suggestion.context")
            if not context_ok then
                print("Context module not loaded")
                return
            end

            local file_context = context.get()
            if not file_context then
                print("No context available for this file")
                return
            end

            print("File Context:")
            print("  Class: " .. (file_context.class_name or "N/A"))
            print("  Type: " .. (file_context.class_type or "N/A"))
            print("  Package: " .. (file_context.package or "N/A"))

            if file_context.annotations and #file_context.annotations > 0 then
                print("  Annotations: " .. table.concat(file_context.annotations, ", "))
            end

            if file_context.fields and #file_context.fields > 0 then
                print("  Fields:")
                for _, f in ipairs(file_context.fields) do
                    local info = f.name .. ": " .. (f.type or "?")
                    if f.injected then info = info .. " (injected)" end
                    if f.static then info = info .. " (static)" end
                    print("    - " .. info)
                end
            end

            if file_context.methods and #file_context.methods > 0 then
                print("  Methods: " .. table.concat(file_context.methods, ", "))
            end
        end, { desc = "Analyze current file context" })

        -- Framework detection command
        vim.api.nvim_create_user_command("FrameworkDetect", function()
            local framework_ok, framework = pcall(require, "suggestion.framework")
            if not framework_ok then
                print("Framework module not loaded")
                return
            end

            local info = framework.detect()
            if info then
                print(string.format("Detected: %s (%s)", info.name, info.id))
            else
                print("No framework detected")
            end
        end, { desc = "Detect project framework" })

        -- AI commands
        vim.api.nvim_create_user_command("AIStatus", function()
            if ai_ok then
                local status = ai.status()
                print(string.format(
                    "AI: enabled=%s, ready=%s, model=%s",
                    tostring(status.enabled),
                    tostring(status.client_ready),
                    status.model
                ))
                print(string.format(
                    "Cache: mem=%d, disk=%d, patterns=%d | hits=%d, misses=%d (%.0f%%)",
                    status.cache_memory or 0,
                    status.cache_disk or 0,
                    status.cache_patterns or 0,
                    status.cache_hits or 0,
                    status.cache_misses or 0,
                    status.hit_rate or 0
                ))
                if (status.saved_tokens or 0) > 0 then
                    print(string.format("Tokens saved: ~%d (patterns reused)", status.saved_tokens))
                end
            else
                print("AI module not loaded")
            end
        end, { desc = "Show AI status" })

        -- Debug command to check API key loading
        vim.api.nvim_create_user_command("AIDebug", function()
            -- Check environment variable
            local env_key = os.getenv("ANTHROPIC_API_KEY")
            if env_key and env_key ~= "" then
                print("ENV: ANTHROPIC_API_KEY found (" .. #env_key .. " chars, starts with: " .. env_key:sub(1, 10) .. "...)")
            else
                print("ENV: ANTHROPIC_API_KEY not set")
            end

            -- Check config file
            local config_path = vim.fn.expand("~/.config/anthropic/api_key")
            if vim.fn.filereadable(config_path) == 1 then
                local content = vim.fn.readfile(config_path)
                if content and #content > 0 then
                    local key = vim.trim(content[1])
                    if key ~= "" then
                        print("FILE: " .. config_path .. " found (" .. #key .. " chars, starts with: " .. key:sub(1, 10) .. "...)")
                    else
                        print("FILE: " .. config_path .. " exists but is empty")
                    end
                else
                    print("FILE: " .. config_path .. " exists but couldn't read")
                end
            else
                print("FILE: " .. config_path .. " not found")
            end

            -- Check client state
            local client = require("suggestion.ai.client")
            local is_init = client.is_initialized()
            print("Client initialized: " .. tostring(is_init))
        end, { desc = "Debug API key loading" })

        vim.api.nvim_create_user_command("AIToggle", function()
            if ai_ok then
                ai.toggle()
                local status = ai.status()
                print("AI: " .. (status.enabled and "enabled" or "disabled"))
            else
                print("AI module not loaded")
            end
        end, { desc = "Toggle AI suggestions" })

        vim.api.nvim_create_user_command("AIInit", function()
            if ai_ok then
                local success = ai.init()
                if success then
                    print("AI initialized successfully")
                else
                    print("AI initialization failed")
                end
            else
                print("AI module not loaded")
            end
        end, { desc = "Initialize AI (prompt for API key)" })

        vim.api.nvim_create_user_command("AITest", function(opts)
            if not ai_ok then
                print("AI module not loaded")
                return
            end

            local method_name = opts.args
            if method_name == "" then
                print("Usage: :AITest <method_name>")
                return
            end

            print("Generating AI suggestion for: " .. method_name)

            ai.generate_async(method_name, nil, nil, function(suggestion, err)
                vim.schedule(function()
                    if err then
                        print("Error: " .. err)
                    elseif suggestion then
                        print("AI Suggestion:")
                        print(suggestion)
                    else
                        print("No suggestion generated")
                    end
                end)
            end)
        end, { nargs = 1, desc = "Test AI suggestion for a method" })

        vim.api.nvim_create_user_command("AIContext", function()
            if not ai_ok then
                print("AI module not loaded")
                return
            end

            local context = ai.build_context("exampleMethod", nil, nil)
            local formatted = ai.format_context(context)
            print("AI Context:")
            print(formatted)
        end, { desc = "Show AI context for current file" })

        vim.api.nvim_create_user_command("AIClearCache", function(opts)
            if ai_ok then
                if opts.bang then
                    -- Full clear with !
                    ai.clear_all_cache()
                    print("AI cache cleared (memory + disk)")
                else
                    ai.clear_cache()
                    print("AI memory cache cleared (disk cache preserved)")
                end
            else
                print("AI module not loaded")
            end
        end, { bang = true, desc = "Clear AI cache (! for full clear)" })

        vim.api.nvim_create_user_command("AIModel", function(opts)
            if not ai_ok then
                print("AI module not loaded")
                return
            end

            if opts.args == "" then
                print("Current model: " .. ai.get_model())
                print("Shortcuts: fast/haiku (cheap), smart/sonnet (quality)")
            else
                ai.set_model(opts.args)
                print("Model set to: " .. ai.get_model())
            end
        end, { nargs = "?", desc = "Get or set AI model (fast|smart|<model-id>)" })
    end,
}
