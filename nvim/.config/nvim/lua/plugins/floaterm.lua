return {
  "voldikss/vim-floaterm",
  cmd = { "FloatermNew", "FloatermToggle" },
  init = function()
    vim.g.floaterm_borderchars = "─│─│╭╮╯╰"
    vim.g.floaterm_title = " Terminal ($1/$2) "
    vim.g.floaterm_width = 0.95
    vim.g.floaterm_height = 0.95
  end,
  keys = {
    {
      "<C-/>",
      function()
        local bufnr = vim.fn["floaterm#terminal#get_bufnr"]("splitterm")
        if bufnr == -1 then
          vim.cmd("FloatermNew --name=splitterm --wintype=split --position=bottom --height=0.5")
        else
          vim.cmd("FloatermToggle splitterm")
        end
      end,
      desc = "Toggle split terminal",
      mode = { "n", "t" },
    },
    {
      "<C-.>",
      function()
        local bufnr = vim.fn["floaterm#terminal#get_bufnr"]("floatterm")
        if bufnr == -1 then
          vim.cmd("FloatermNew --name=floatterm --wintype=float --position=center --width=0.95 --height=0.95")
        else
          vim.cmd("FloatermToggle floatterm")
        end
      end,
      desc = "Toggle floating terminal",
      mode = { "n", "t" },
    },
  },
}
