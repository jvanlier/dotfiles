-- Visual debugger (replaces the ideavimrc Debug/Run maps).
-- Requires: pip install debugpy in the project venv being debugged.

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",  -- required by nvim-dap-ui v4+
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>",           desc = "Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>",                   desc = "Continue / start debug" },
      { "<leader>dr", "<cmd>DapToggleRepl<cr>",                 desc = "Toggle REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>dd", "<cmd>DapContinue<cr>",                   desc = "Debug (continue)" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Uses the active pyenv python; debugpy must be installed in the project venv.
      local python_bin = vim.fn.exepath("python3") ~= "" and "python3" or "python"
      require("dap-python").setup(python_bin)
    end,
  },
}
