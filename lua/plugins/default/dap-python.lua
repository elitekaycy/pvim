return {
    "mfussenegger/nvim-dap-python",
    ft = { "python" },
    dependencies = {
        "mfussenegger/nvim-dap",
    },
    config = function()
        local ok, dap_python = pcall(require, "dap-python")
        if not ok then
            return
        end

        local python = vim.fn.exepath("python3")
        if python == "" then
            python = vim.fn.exepath("python")
        end

        if python ~= "" then
            dap_python.setup(python)
        end
    end,
}
