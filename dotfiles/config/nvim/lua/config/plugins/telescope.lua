return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Help tags" },
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    -- fd binary is 'fdfind' on Debian/Ubuntu; fall back gracefully.
    local fd_cmd = vim.fn.executable("fd") == 1 and "fd" or "fdfind"

    telescope.setup({
      defaults = {
        mappings = {
          i = { ["<C-q>"] = actions.send_to_qflist },
        },
      },
      pickers = {
        find_files = {
          find_command = { fd_cmd, "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
        },
      },
    })

    telescope.load_extension("fzf")
  end,
}
