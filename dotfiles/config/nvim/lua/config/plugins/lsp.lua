-- LSP setup using mason-lspconfig 2.0 API + neovim 0.11+ native vim.lsp.config.
-- setup_handlers was removed in mason-lspconfig 2.0; use automatic_enable instead.

local is_headless = #vim.api.nvim_list_uis() == 0

return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = is_headless and {} or {
          "basedpyright",
          "ruff",
          "lua_ls",
          "jsonls",
          "yamlls",
        },
        -- automatic_enable calls vim.lsp.enable() for installed servers.
        -- Disabled headlessly so CI docker builds do not attempt LSP binary downloads.
        automatic_enable = not is_headless,
      })

      -- Per-server settings via native nvim 0.11+ API.
      -- blink.cmp v1 auto-registers completion capabilities into vim.lsp.config("*"),
      -- so no manual capability wiring is needed here.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              -- "standard" suits ML code which often has Any types.
              typeCheckingMode = "standard",
            },
          },
        },
      })

      -- Buffer-local keymaps on LSP attach.
      -- nvim 0.11 ships grn/gra/grr/gri/gO/K/[d/]d by default;
      -- these add IDE-flavoured aliases and a legacy <leader>g binding.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local b = ev.buf
          local function map(k, fn, d)
            vim.keymap.set("n", k, fn, { buffer = b, desc = d })
          end
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
          map("<leader>g", vim.lsp.buf.definition, "Goto definition (legacy)")
        end,
      })
    end,
  },
}
