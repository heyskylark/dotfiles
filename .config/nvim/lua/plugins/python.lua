return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
  },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      name = { ".venv", "venv" },
      auto_refresh = true,
    },
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<cr>" },
    },
  },
}

