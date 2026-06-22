return {
  -- Plugin 1
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>bi",
        function()
          require("telescope.builtin").buffers({ sort_mru = true, ignore_current_buffer = false })
        end,
        desc = "Buffer List",
      },
    },
  },
  -- Plugin 2
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
  },
}
