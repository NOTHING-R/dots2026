return {
  {
    "akinsho/bufferline.nvim",
    enabled = true,
    opts = {
      options = {
        always_show_bufferline = false,
      },
    },
    init = function()
      vim.opt.showtabline = 0
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    opts = {
      options = {
        globalstatus = true,
      },
    },
    init = function()
      vim.g.lualine_laststatus = 0 -- lualine saves this and restores it, so force it to 0
      vim.o.laststatus = 0
    end,
  },
}
