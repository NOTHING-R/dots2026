-- Map Ctrl+Backspace to delete previous word in insert mode (like Ctrl-w)
vim.keymap.set("i", "<C-BS>", "<C-w>", { desc = "Delete previous word" })

-- Fallback for terminals that send Ctrl+H for Ctrl+Backspace
vim.keymap.set("i", "<C-H>", "<C-w>", { desc = "Delete previous word (fallback)" })

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ==========================
-- JJ FOR ESC
-- ==========================
map("i", "jj", "<Esc>", opts)
map("n", "<leader>nn", "zt", opts)

-- Disable LazyVim's default <leader>bb
vim.keymap.del("n", "<leader>bb")

-- Remap Lazy UI from <leader>l to <leader>ll
vim.keymap.del("n", "<leader>l")
map("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- toggel fold for codes
vim.keymap.set("n", "<Tab>", "za", { desc = "Toggle fold" })
map("n", "<leader>J", ":Ex ", opts)
-- ==========================
-- Window Management (SPC-w)
-- ==========================
map("n", "<leader>ww", "<C-w>w", { desc = "Switch to next window" })
map("n", "<leader>wv", "<C-w>v", { desc = "Vertical split" })
map("n", "<leader>ws", "<C-w>s", { desc = "Horizontal split" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close window" })

-- ==========================
-- Buffer Management (SPC-b)
-- ==========================
map("n", "<leader>j", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>k", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>hh", "<cmd>bdelete<CR>", { desc = "Kill/Close buffer" })

-- Help / Info (SPC-h)
-- ==========================
map("n", "<leader>hk", "<cmd>help<CR>", { desc = "Vim help" })
map("n", "<leader>hm", "<cmd>:messages<CR>", { desc = "Show messages" })

-- extra added
vim.keymap.set("n", "<leader>fs", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Swiper-like search (buffer)" })

-- for jj exit on terminal
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
vim.keymap.set("t", "jj", [[<C-\><C-n>]], { noremap = true, silent = true })

-- ==========================
-- PERSONAL FOLDER SHORTCUTS (SPC-f-p)
-- ==========================
vim.keymap.set("n", "<leader>faa", function()
  require("telescope.builtin").find_files({ cwd = "~/my-shared-fiels/Progrmain Notes/" })
end, { desc = "Find in Notes" })

-- FUZZY FIND
-- Previous code
-- local fb = require("telescope").extensions.file_browser
-- local wk = require("which-key")
--
-- wk.add({
--   {
--     "<leader>.",
--     function()
--       fb.file_browser({
--         path = vim.fn.expand("%:p:h"), -- current file dir (IMPORTANT)
--         select_buffer = true,
--       })
--     end,
--     desc = "File Browser (current dir)",
--   },
-- })
-- This is a simpler way to set the keymap without using which-key
vim.keymap.set("n", "<leader>.", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("%:p:h"),
    select_buffer = true,
  })
end, { desc = "File Browser (current dir)" })

vim.keymap.set("n", "<leader><space>", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] or vim.fn.getcwd(),
  })
end, { desc = "Find Files from git root" })

-- ==========================
-- OPEN VIDEO UNDER CURSOR WITH MPV
-- ==========================
vim.keymap.set("n", "<leader>ov", function()
  local file = vim.fn.expand("<cfile>")
  vim.fn.jobstart({ "mpv", file }, { detach = true })
end, { desc = "Open video in mpv" })

-- ------------------------------
-- COPILOT TOGGLE
-- ------------------------------

vim.keymap.set("n", "<leader>cp", function()
  if vim.g.copilot_enabled == false then
    vim.cmd("Copilot enable")
    vim.g.copilot_enabled = true
    vim.notify("Copilot ON", vim.log.levels.INFO)
  else
    vim.cmd("Copilot disable")
    vim.g.copilot_enabled = false
    vim.notify("Copilot OFF", vim.log.levels.INFO)
  end
end, { desc = "Toggle Copilot" })
