-- C/C++ DAP configuration using codelldb
local dap = require("dap")
local mason_registry = require("mason-registry")

-- Setup codelldb adapter from mason
local function setup_codelldb()
    if not mason_registry.is_installed("codelldb") then
        vim.notify("codelldb not installed. Run :MasonInstall codelldb", vim.log.levels.WARN)
        return
    end

    local codelldb_path = mason_registry.get_package("codelldb"):get_install_path()
    local codelldb_bin = codelldb_path .. "/extension/adapter/codelldb"
    local liblldb_path = codelldb_path .. "/extension/lldb/lib/liblldb.so"

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            command = codelldb_bin,
            args = { "--port", "${port}" },
        },
    }

    -- Also register as 'lldb' for compatibility
    dap.adapters.lldb = dap.adapters.codelldb
end

-- Setup adapter
setup_codelldb()

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
