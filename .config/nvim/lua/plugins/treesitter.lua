return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "lua", "vim", "bash", "json", "toml", "javascript", "rust", "toml", "markdown", "markdown_inline" },
      highlight = { enable = true },
      indent = { enable = true },
    }
  }
}
