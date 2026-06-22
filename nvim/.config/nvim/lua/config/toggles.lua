-- =========================
-- UI STATE
-- =========================
-- Single source of truth: start hidden
vim.g.ui_hidden = true

-- =========================
-- ENFORCE HIDDEN STATE AFTER ALL PLUGINS LOAD
-- =========================
-- Plugins like lualine reset laststatus on startup, so we enforce
-- our hidden state after everything is initialized via VimEnter.
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  once = true,
  callback = function()
    vim.g.lualine_laststatus = 0
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
  end,
})

vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "TabEnter" }, {
  callback = function()
    if vim.g.ui_hidden then
      vim.opt.showtabline = 0
    end
  end,
})

-- =========================
-- STATUSLINE TOGGLE (lualine-safe)
-- =========================
vim.keymap.set("n", "<leader>ts", function()
  vim.g.ui_hidden = not vim.g.ui_hidden

  if vim.g.ui_hidden then
    vim.opt.laststatus = 0
  else
    vim.opt.laststatus = 3
  end

  vim.cmd("redrawstatus")
end, { desc = "Toggle Statusline" })

-- =========================
-- BUFFERLINE TOGGLE (SAFE WAY)
-- =========================
vim.keymap.set("n", "<leader>ut", function()
  vim.g.ui_hidden = not vim.g.ui_hidden

  if vim.g.ui_hidden then
    vim.opt.showtabline = 0
    vim.cmd("redrawtabline")
  else
    vim.opt.showtabline = 2
    vim.cmd("redrawtabline")
  end
end, { desc = "Toggle Bufferline" })

-- =========================
-- ULTRA MINIMAL MODE (toggle both together)
-- =========================
vim.keymap.set("n", "<leader>uu", function()
  vim.g.ui_hidden = not vim.g.ui_hidden

  if vim.g.ui_hidden then
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
  else
    vim.opt.laststatus = 3
    vim.opt.showtabline = 2
  end

  vim.cmd("redrawstatus")
  vim.cmd("redrawtabline")
end, { desc = "Toggle UI (Minimal Mode)" })
