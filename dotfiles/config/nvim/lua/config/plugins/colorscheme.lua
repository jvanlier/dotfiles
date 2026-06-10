return {
  "phha/zenburn.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("zenburn").setup()
    vim.cmd.colorscheme("zenburn")
  end,
}
