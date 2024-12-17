local dap            = require('dap')
local mason_registry = require("mason-registry")

-- local java_debug_adapter_path =
--     mason_registry.get_package('java-debug-adapter')
--     :get_install_path()

local java_test_path = mason_registry.get_package("java-test"):get_install_path()
local jdtls_path     = mason_registry.get_package("jdtls"):get_install_path()


dap.adapters.java = function(callback)
    callback({
        type = 'server',
        host = '127.0.0.1',
        port = 0,
        executable = {
            command = 'java',
            args = {
                '-Xmx1g',
                '-jar',
                -- java_debug_adapter_path .. '/extension/server/com.microsoft.java.debug.plugin-0.38.0.jar',
                '--parsing-debounce-delay=200'
            }
        }
    })
end


dap.configurations.java = {
    -- Run Current File
    {
        type = 'java',
        request = 'launch',
        name = 'Debug Current File',
        mainClass = function()
            return vim.fn.input('Main class: ')
        end,
        args = function()
            local args_string = vim.fn.input('Program arguments: ')
            return vim.split(args_string, ' ')
        end,
        cwd = '${workspaceFolder}',
        console = 'internalConsole',
        stopOnEntry = false,
    },

    -- Run JUnit Test
    {
        type = 'java',
        request = 'launch',
        name = 'Debug JUnit Test',
        mainClass = 'org.junit.runners.JUnit4',
        args = function()
            local test_class = vim.fn.input('Test class name: ')
            return { test_class }
        end,
        cwd = '${workspaceFolder}',
        console = 'internalConsole',
        testClass = function()
            return vim.fn.input('Test class name: ')
        end
    },

    -- Remote Debug Configuration
    {
        type = 'java',
        request = 'attach',
        name = 'Remote Debug',
        hostName = 'localhost',
        port = 5005,
    }
}
