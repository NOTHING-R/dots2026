vim.opt.clipboard = "unnamedplus" -- For using global clipboard

vim.opt.termguicolors = true
vim.g.root_spec = { "cwd" }

vim.g.inlay_hints_enabled = false -- it was true

-- For line warp
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:2"
vim.opt.showbreak = ""
vim.opt.conceallevel = 2
vim.opt.concealcursor = "nv"

-- statusline + tabline are managed by lua/config/toggles.lua (hidden by default)

-- Extra added for directory
vim.opt.autochdir = false -- এটা off রাখাই better

vim.opt.foldmethod = "expr"
-- change this:
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- to this:
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldenable = false -- don't fold everything on open
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.foldtext = ""
vim.opt.fillchars = { fold = " " }

vim.opt.laststatus = 0
vim.opt.showtabline = 0

vim.opt.ruler = false
vim.opt.showcmd = false
vim.opt.showmode = false

vim.opt.shortmess = vim.opt.shortmess + "W" + "w" + "F"
-- for the picker
vim.g.lazyvim_picker = "telescope"
-- for auto completion
vim.g.lazyvim_cmp = "blink.cmp"
