vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "silent! write",
})

-- For disableing speelcheck on md files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- for markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("i", ";", function()
      local line = vim.api.nvim_get_current_line()
      if line:match("^%s*$") then
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, {
          "```",
          "",
          "```",
        })
        -- Move cursor to end of first ``` line
        vim.api.nvim_win_set_cursor(0, { row, 3 })
      else
        vim.api.nvim_feedkeys(";", "n", false)
      end
    end, { noremap = true, silent = true, buffer = true })
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("echon ''")
    end, 1)
  end,
})

-- Disable auto-continuing comments on Enter / o / O
-- This stops * , # , #+ etc. from repeating on new lines
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- Optional: Also apply it when filetype is detected (extra safety)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    -- vim.opt_local.breakindentopt = "shift:2"
    -- Make wrapped lines look clean
    vim.opt_local.showbreak = " "
    -- 👉 THIS fixes heading paragraph issue
    vim.opt_local.indentexpr = " "
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "LineNr",
      "EndOfBuffer",
      "TelescopeNormal",
      "TelescopeBorder",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
    }
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
    -- Folded gets its own fg too
    vim.api.nvim_set_hl(0, "Folded", { bg = "NONE", fg = "#545c7e" })
  end,
})
