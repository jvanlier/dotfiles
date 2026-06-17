return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
  },
  config = function()
    require("neo-tree").setup({
      window = { width = 35 },
      filesystem = {
        filtered_items = { hide_dotfiles = false },
        follow_current_file = { enabled = true },
      },
    })
  end,
}
