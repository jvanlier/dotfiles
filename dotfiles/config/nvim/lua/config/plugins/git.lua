return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(k, fn, d)
          vim.keymap.set("n", k, fn, { buffer = bufnr, desc = d })
        end
        map("<leader>hp", gs.preview_hunk, "Preview hunk")
        map("<leader>hb", gs.blame_line, "Blame line")
        map("]c", gs.next_hunk, "Next hunk")
        map("[c", gs.prev_hunk, "Prev hunk")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gblame" },
  },
}
