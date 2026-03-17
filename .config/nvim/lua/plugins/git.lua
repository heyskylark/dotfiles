return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
      },

      signcolumn = true,   -- git markers in the gutter
      numhl      = false,  -- highlight line numbers
      linehl     = false,  -- highlight full lines
      word_diff  = false,

      watch_gitdir = {
        follow_files = true,
      },

      current_line_blame = false,
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- hunk navigation
        map("n", "]c", gs.next_hunk, "Next hunk")
        map("n", "[c", gs.prev_hunk, "Prev hunk")

        -- hunk actions
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
      end,
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gedit" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Fugitive status" },
      { "<leader>gd", "<cmd>Gvdiffsplit<cr>", desc = "Fugitive diff split" },
    },
  },
}

