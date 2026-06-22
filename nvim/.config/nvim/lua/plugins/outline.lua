return {
  "hedyhli/outline.nvim",
  lazy = true,
  cmd = { "Outline", "OutlineOpen" },
  keys = { -- Example mapping to toggle outline
    { "<leader>oo", "<cmd>Outline<CR>", desc = "Toggle outline" },
  },
  opts = {
    -- Your setup opts here
    window = {
      width = 40, -- increase from default (30) to your preference
      auto_width = true, -- automatically adjusts width to fit content
      relative_width = false, -- set true if you want width as a % of screen
    },
  },
}
