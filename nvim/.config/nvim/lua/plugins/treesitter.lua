return {
  -- JSX/TSX syntax highlighting & tag support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed or {}, {
        "javascript",
        "typescript",
        "tsx",
        "css",
        "html",
        "json",
      })
    end,
  },

  -- Auto close/rename JSX tags (like VS Code)
  {
    "windwp/nvim-ts-autotag",
    opts = {
      options = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },
}
