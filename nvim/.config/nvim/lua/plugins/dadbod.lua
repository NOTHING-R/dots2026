return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      "tpope/vim-dadbod",
      "kristijanhusak/vim-dadbod-completion",
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },

    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          vim.keymap.set("n", "<leader>dq", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute DB query" })
          vim.keymap.set("n", "<leader>ds", "<Plug>(DBUI_SaveQuery)", { buffer = true, desc = "Save DB query" })
        end,
      })
    end,

    keys = {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add DB connection" },
      { "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find DB buffer" },
    },
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    lazy = true,
  },

  -- Extend YOUR existing blink.cmp spec (optional = true merges, never replaces)
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot", "dadbod" },
        providers = {
          dadbod = {
            name = "dadbod",
            module = "vim_dadbod_completion.blink",
            score_offset = 85,
          },
        },
      },
    },
  },
}
