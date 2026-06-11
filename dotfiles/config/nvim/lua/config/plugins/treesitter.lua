return {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.10.0",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "python", "lua", "bash",
        "json", "yaml", "toml",
        "markdown", "markdown_inline",
        "dockerfile", "sql", "hcl",
        "vim", "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
