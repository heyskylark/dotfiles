return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = { "renders/", "experiments/", "wandb/", ".next/", "dist/", "^build[^/]*/", "build/", "build-local/", "%.venv/", "__pycache__/", ".git/", "node_modules/" },
      },
      pickers = {
        find_files = {
          hidden = true,     -- include dotfiles
          no_ignore = true,  -- do not respect .gitignore
          no_ignore_parent = true,
        },
      },
    },
    config = function(_, opts)
      require("telescope").setup(opts)
    end,
  },
}

