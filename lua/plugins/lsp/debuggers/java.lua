-- Java DAP configuration
-- Note: The actual debug adapter is set up by jdtls.setup_dap() in java.lua
-- This file provides additional DAP configurations for Java debugging

local dap = require("dap")

-- DAP configurations for Java (used with nvim-jdtls)
-- The adapter is automatically configured by jdtls.setup_dap()
dap.configurations.java = {
    -- Debug Current File
    {
        type = "java",
        request = "launch",
        name = "Debug Current File",
        mainClass = function()
            return vim.fn.input("Main class: ")
        end,
        args = function()
            local args_string = vim.fn.input("Program arguments: ")
            return vim.split(args_string, " ")
        end,
        cwd = "${workspaceFolder}",
        console = "internalConsole",
        stopOnEntry = false,
    },

    -- Debug JUnit Test
    {
        type = "java",
        request = "launch",
        name = "Debug JUnit Test",
        mainClass = "org.junit.platform.console.ConsoleLauncher",
        args = function()
            local test_class = vim.fn.input("Test class name: ")
            return { "--select-class=" .. test_class }
        end,
        cwd = "${workspaceFolder}",
        console = "internalConsole",
    },

    -- Remote Debug (attach to running JVM)
    {
        type = "java",
        request = "attach",
        name = "Remote Debug (port 5005)",
        hostName = "localhost",
        port = 5005,
    },

    -- Debug with custom JVM args
    {
        type = "java",
        request = "launch",
        name = "Debug with Custom Args",
        mainClass = function()
            return vim.fn.input("Main class: ")
        end,
        vmArgs = function()
            return vim.fn.input("VM arguments (e.g., -Xmx2g): ")
        end,
        args = function()
            local args_string = vim.fn.input("Program arguments: ")
            return vim.split(args_string, " ")
        end,
        cwd = "${workspaceFolder}",
        console = "internalConsole",
    },
}
