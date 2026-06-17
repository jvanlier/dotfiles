-- Pinned to a specific commit on the `main` branch (not a release tag).
--
-- Why not a tag: the newest tag (v0.10.0) lives on the frozen `master` branch,
-- which only supports Neovim up to 0.11. On Neovim 0.12 its bundled markdown
-- injection query crashes the highlighter ("attempt to call method 'range' (a
-- nil value)") because 0.12 passes query-directive captures as a node *list*
-- instead of a single node, which master's custom directives don't handle.
--
-- The `main` branch is the rewrite targeting Neovim 0.12+, but it is unreleased
-- (no tags point at it). We pin a commit instead of tracking the branch tip so
-- `:Lazy sync` stays reproducible. Bump the commit deliberately when updating.
--
-- The rewrite is a different plugin: setup() only configures install_dir (we use
-- the default, stdpath('data')/site, already on runtimepath), parsers are fetched
-- via :TSUpdate / install() using the tree-sitter CLI, and highlight/indent are
-- enabled per-buffer through Neovim core rather than a `highlight`/`indent` table.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  commit = "4916d6592ede8c07973490d9322f187e07dfefac",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    local ensure_installed = {
      "python", "lua", "bash",
      "json", "yaml", "toml",
      "markdown", "markdown_inline",
      "dockerfile", "sql", "hcl",
      "vim", "vimdoc",
    }
    -- No-op for parsers already installed; builds the rest with the tree-sitter CLI.
    require("nvim-treesitter").install(ensure_installed)

    -- Highlight and indent are provided by Neovim core on the main branch; enable
    -- them per-buffer. pcall guards filetypes whose parser isn't installed yet.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter_enable", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang and pcall(vim.treesitter.start, args.buf, lang) then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
