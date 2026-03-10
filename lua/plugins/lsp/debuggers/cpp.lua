-- C/C++ DAP configuration using codelldb
local dap = require("dap")

-- Setup codelldb adapter from mason (deferred to avoid startup errors)
local function setup_codelldb()
    local ok, mason_registry = pcall(require, "mason-registry")
    if not ok then return false end

    -- Check if codelldb is installed
    local installed = pcall(function()
        return mason_registry.is_installed("codelldb")
    end)

    if not installed or not mason_registry.is_installed("codelldb") then
        return false
    end

    local codelldb_pkg = mason_registry.get_package("codelldb")
    if not codelldb_pkg then return false end

    local path_ok, codelldb_path = pcall(function()
        return codelldb_pkg:get_install_path()
    end)
    if not path_ok then return false end
    local codelldb_bin = codelldb_path .. "/extension/adapter/codelldb"

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = codelldb_bin,
            args = { "--port", "${port}" },
        },
    }

    dap.adapters.lldb = dap.adapters.codelldb
    return true
end

-- Try to setup adapter (silently fail if not installed)
vim.defer_fn(function()
    if not setup_codelldb() then
        -- Setup will be retried when user opens C/C++ file
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "c", "cpp", "rust" },
            once = true,
            callback = function()
                if not setup_codelldb() then
                    vim.notify("codelldb not installed. Run :MasonInstall codelldb", vim.log.levels.INFO)
                end
            end,
        })
    end
end, 1000)

-- C/C++ debug configurations
dap.configurations.cpp = {
    -- Debug executable
    {
        type = "codelldb",
        request = "launch",
        name = "Launch Executable",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
            local args_string = vim.fn.input("Program arguments: ")
            if args_string == "" then
                return {}
            end
            return vim.split(args_string, " ")
        end,
    },

    -- Debug with core dump
    {
        type = "codelldb",
        request = "launch",
        name = "Launch with Core Dump",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        coreFile = function()
            return vim.fn.input("Path to core dump: ", vim.fn.getcwd() .. "/", "file")
        end,
    },

    -- Attach to running process
    {
        type = "codelldb",
        request = "attach",
        name = "Attach to Process",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
    },

    -- Debug current file (compile and run)
    {
        type = "codelldb",
        request = "launch",
        name = "Build and Debug Current File",
        program = function()
            local file = vim.fn.expand("%:p")
            local output = vim.fn.expand("%:p:r")
            -- Compile with debug symbols
            local compile_cmd = string.format("g++ -g -o %s %s", output, file)
            vim.fn.system(compile_cmd)
            return output
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

-- Use same configuration for C
dap.configurations.c = dap.configurations.cpp

-- Rust can also use codelldb
dap.configurations.rust = {
    {
        type = "codelldb",
        request = "launch",
        name = "Launch Rust Executable",
        program = function()
            -- Try to find target/debug executable
            local crate_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
            local default_path = vim.fn.getcwd() .. "/target/debug/" .. crate_name
            return vim.fn.input("Path to executable: ", default_path, "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
            local args_string = vim.fn.input("Program arguments: ")
            if args_string == "" then
                return {}
            end
            return vim.split(args_string, " ")
        end,
    },
    {
        type = "codelldb",
        request = "attach",
        name = "Attach to Rust Process",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
    },
}
