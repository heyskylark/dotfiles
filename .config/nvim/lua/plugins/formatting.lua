return { 
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        local format_fts = {
          python = true,
          c = true,
          cpp = true,
          javascript = true,
          typescript = true,
          javascriptreact = true,
          typescriptreact = true,
          json = true,
          css = true,
          markdown = true,
        }
        if format_fts[ft] then
          return { timeout_ms = 1000, lsp_fallback = true }
        end
        return nil
      end,
    },
  },
}


