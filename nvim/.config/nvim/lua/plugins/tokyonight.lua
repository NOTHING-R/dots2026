return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.Folded = { bg = "NONE", fg = c.comment }
        hl.CursorLine = { bg = "NONE" }
        hl.CursorLineNr = { fg = "#aaaaaa" }
      end,
    },
  },
}
