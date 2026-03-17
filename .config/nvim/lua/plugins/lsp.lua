return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "basedpyright",
        "lua_ls",
        "ts_ls",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local util = require("lspconfig.util")

      local function on_attach(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end

        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gD", vim.lsp.buf.declaration)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K", vim.lsp.buf.hover)
        map("n", "<leader>ca", vim.lsp.buf.code_action)
        map("n", "<leader>rn", vim.lsp.buf.rename)
      end

      vim.diagnostic.config({
        virtual_text = false,
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- =========================
      -- C / C++
      -- =========================
      vim.lsp.config("clangd", {
        capabilities = caps,
        on_attach = on_attach,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--header-insertion=never",
        },
      })

      -- =========================
      -- Python
      -- =========================
      vim.lsp.config("basedpyright", {
        capabilities = caps,
        on_attach = on_attach,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- =========================
      -- Lua (Neovim config)
      -- =========================
      vim.lsp.config("lua_ls", {
        capabilities = caps,
        on_attach = on_attach,
        root_dir = function(fname)
          return util.root_pattern(".luarc.json", ".luarc.jsonc", ".git")(fname)
            or vim.fn.stdpath("config")
        end,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      -- =========================
      -- TypeScript / JavaScript
      -- =========================
      vim.lsp.config("ts_ls", {
        capabilities = caps,
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          on_attach(client, bufnr)
        end,
      })

      vim.lsp.enable({
        "clangd",
        "basedpyright",
        "lua_ls",
        "ts_ls",
        "tsserver",
      })
    end,
  },
}

