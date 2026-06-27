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

-- ==========================
-- ORG MODE
-- ==========================
local org = vim.keymap.set

-- Agenda views
org("n", "<leader>oa", "<cmd>lua require('orgmode').action('agenda.prompt')<CR>", { desc = "Org Agenda" })
org("n", "<leader>ot", "<cmd>lua require('orgmode').action('agenda.todos')<CR>", { desc = "Org TODO list" })
org("n", "<leader>oc", "<cmd>lua require('orgmode').action('capture.prompt')<CR>", { desc = "Org Capture" })

-- Telescope orgmode
org("n", "<leader>oh", "<cmd>Telescope orgmode search_headings<CR>", { desc = "Search org headings" })
org("n", "<leader>or", "<cmd>Telescope orgmode refile_heading<CR>", { desc = "Refile heading" })

-- Quick file access
org("n", "<leader>ofi", "<cmd>e ~/orgfiles/inbox.org<CR>", { desc = "Open inbox" })
org("n", "<leader>ofj", "<cmd>e ~/orgfiles/journal.org<CR>", { desc = "Open journal" })
org("n", "<leader>ofn", "<cmd>e ~/orgfiles/notes.org<CR>", { desc = "Open notes" })
org("n", "<leader>ofr", "<cmd>e ~/orgfiles/routine.org<CR>", { desc = "Open notes" })
org("n", "<leader>ofg", "<cmd>e ~/orgfiles/gher.org<CR>", { desc = "Gher er hisab" })
org("n", "<leader>off", "<cmd>e ~/orgfiles/finance.org<CR>", { desc = "Monthly Cost" })

vim.keymap.set("n", "<leader>os", function()
  require("orgmode").action("org_mappings.todo_next_state")
end, { desc = "Org next TODO state" })

-- ==========================
-- MARKDOWN CHECKBOX TOGGLE WITH TIMESTAMP
-- ==========================
vim.keymap.set("n", "<leader>x", function()
  local line = vim.api.nvim_get_current_line()
  local new_line
  local date = os.date("%H:%M")

  if line:match("%[x%]") then
    -- checked → uncheck, remove ✓ timestamp
    new_line = line:gsub(" ✓ %d%d:%d%d$", "")
    new_line = new_line:gsub("%[x%]", "[ ]", 1)
  elseif line:match("%[ %]") then
    -- unchecked → check with ✓ timestamp
    new_line = line:gsub("%[ %]", "[x]", 1)
    new_line = new_line .. " ✓ " .. date
  else
    return
  end

  vim.api.nvim_set_current_line(new_line)
end, { desc = "Toggle markdown checkbox with timestamp" })

-- Add TODO directly to current org file at end of file
vim.keymap.set("n", "<leader>oT", function()
  local current_file = vim.fn.expand("%:p")
  if not current_file:match("%.org$") then
    vim.notify("Not an org file", vim.log.levels.WARN)
    return
  end
  local date = os.date("%Y-%m-%d %a")
  local scheduled = os.date("<%Y-%m-%d %a>")
  -- local created = os.date("<%Y-%m-%d %a %H:%M>")
  local created = os.date("<%Y-%m-%d>")
  local task = vim.fn.input("Task: ")
  if task == "" then
    return
  end
  local lines = {
    "* TODO " .. task,
    "SCHEDULED: " .. created,
    -- "   :PROPERTIES:",
    -- "   :CREATED: " .. created,
    -- "   :END:",
    "",
  }
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    table.insert(buf_lines, line)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, buf_lines)
  vim.cmd("silent write")
  vim.notify("Task added to " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
end, { desc = "Add TODO to current org file" })

-- ==========================
-- ADD NEW CHECKBOX WITH TIMESTAMP
-- ==========================
-- vim.keymap.set("n", "<leader>cb", function()
--   -- local date = os.date("%a %b %d %Y %H:%M => ")
--   local date = os.date("%a %b %d %Y %H:%M => ")
--   local line_num = vim.api.nvim_win_get_cursor(0)[1]
--   local current_line = vim.api.nvim_get_current_line()
--   local indent = current_line:match("^(%s*)") or "   "
--   local new_line = indent .. "- [ ] " .. date .. " "
--   vim.api.nvim_buf_set_lines(0, line_num, line_num, false, { new_line })
--   vim.api.nvim_win_set_cursor(0, { line_num + 1, #new_line })
--   vim.cmd("startinsert!")
-- end, { desc = "Add new checkbox with creation timestamp" })

vim.keymap.set("n", "<leader>cb", function()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_get_current_line()
  local indent = current_line:match("^(%s*)") or "   "
  local new_line = indent .. "- [ ] "
  vim.api.nvim_buf_set_lines(0, line_num, line_num, false, { new_line })
  vim.api.nvim_win_set_cursor(0, { line_num + 1, #new_line })
  vim.cmd("startinsert!")
end, { desc = "Add new checkbox" })

-- ==========================
-- CHECKBOX TIMESTAMP HIGHLIGHTS
-- ==========================
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.md", "*.org" },
  callback = function()
    -- Creation time [Sat Jun 28 2026 09:15] — blue/cyan
    vim.fn.matchadd("CheckboxCreated", "%[%a%a%a %a%a%a %d%d %d%d%d%d %d%d:%d%d%]")
    -- Completion time (Sat Jun 28 2026 10:30) — green
    vim.fn.matchadd("CheckboxDone", "(%a%a%a %a%a%a %d%d %d%d%d%d %d%d:%d%d)")
  end,
})

-- Define the colors
vim.api.nvim_set_hl(0, "CheckboxCreated", { fg = "#7dcfff", bold = false })
vim.api.nvim_set_hl(0, "CheckboxDone", { fg = "#9ece6a", bold = false })
