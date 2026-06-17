return {
  -- Autopairs
  { "echasnovski/mini.pairs", version = false, opts = {} },

  -- Surround (ys/cs/ds motions)
  { "echasnovski/mini.surround", version = false, opts = {} },

  -- Comments: gcc (line), gc (visual)
  {
    "numToStr/Comment.nvim",
    opts = {},
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc",  mode = "v", desc = "Comment selection" },
    },
  },

  -- Flash: replaces easymotion. s = jump, S = treesitter-aware jump.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- Which-key: keymap discovery popup (v4 API with spec groups).
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find (telescope)" },
        { "<leader>g", group = "goto / git" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>h", group = "git hunks" },
        { "<leader>r", group = "refactor" },
        { "<leader>x", group = "diagnostics" },
      },
    },
  },

  -- Trouble: diagnostics panel (v3 API).
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    },
    opts = {},
  },

  -- Toggleterm: integrated terminal.
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
    opts = {
      direction = "horizontal",
      size = 15,
    },
  },
}
