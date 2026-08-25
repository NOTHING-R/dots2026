return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    -- notifier = { enabled = false },

    indent = {
      enabled = true, -- ← This turns on the vertical indent guides permanently
    },
  },
keys = {
    { "<leader>hH", function() Snacks.bufdelete.all() end, desc = "Close all buffers" },
  }
}
