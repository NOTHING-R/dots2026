return {
  -- Copilot (suggestion/panel disabled; only used as a blink.cmp source)
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },

  -- blink.cmp: copilot source + performance tuning
  {
    "saghen/blink.cmp",
    -- dependencies = { "giuxtaposition/blink-copilot" },
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      fuzzy = {
        implementation = "prefer_rust_with_warning", -- force native matcher, warn on lua fallback
      },
      completion = {
        trigger = {
          show_in_snippet = true,
        },
        list = {
          max_items = 50, -- fewer candidates to score/render
        },
        menu = {
          max_height = 10,
        },
        -- documentation = {
        --   auto_show = false, -- skip auto-fetching docs popup, reduces per-keystroke work
        -- },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        min_keyword_length = 2, -- don't fire completion on 1-character input
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}

-- return {}
-- return {
--   { "zbirenbaum/copilot.lua", enabled = false },
--   { "CopilotC-Nvim/CopilotChat.nvim", enabled = false },
--   { "giuxtaposition/blink-copilot", enabled = false },
-- }
-- return {
--   -- Copilot (suggestion/panel disabled; only used as a blink.cmp source)
--   {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--
--     config = function()
--       require("copilot").setup({
--         suggestion = { enabled = false },
--         panel = { enabled = false },
--       })
--     end,
--   },
--
--   -- blink.cmp: copilot source + performance tuning
--   {
--     "saghen/blink.cmp",
--     dependencies = { "giuxtaposition/blink-copilot" },
--     opts = {
--       fuzzy = {
--         implementation = "prefer_rust_with_warning", -- force native matcher, warn on lua fallback
--       },
--       completion = {
--         trigger = {
--           show_in_snippet = true,
--         },
--         list = {
--           max_items = 200, -- fewer candidates to score/render
--         },
--         menu = {
--           max_height = 10,
--         },
--         documentation = {
--           auto_show = false, -- skip auto-fetching docs popup, reduces per-keystroke work
--         },
--       },
--       sources = {
--         default = { "lsp", "path", "snippets", "buffer", "copilot" },
--         min_keyword_length = 2, -- don't fire completion on 1-character input
--         providers = {
--           copilot = {
--             name = "copilot",
--             module = "blink-copilot",
--             score_offset = 100,
--             async = true,
--           },
--         },
--       },
--     },
--   },
-- }

-- This was the main block of code I used previously
-- return {
--   -- Copilot
--   {
--     "zbirenbaum/copilot.lua",
--     cmd = "Copilot",
--     event = "InsertEnter",
--
--     config = function()
--       require("copilot").setup({
--         suggestion = { enabled = false },
--         panel = { enabled = false },
--       })
--     end,
--   },
--
--   -- nvim-cmp
--   {
--     "hrsh7th/nvim-cmp",
--
--     dependencies = {
--       "zbirenbaum/copilot-cmp",
--     },
--
--     config = function()
--       local cmp = require("cmp")
--
--       require("copilot_cmp").setup()
--
--       cmp.setup({
--         sources = cmp.config.sources({
--           { name = "copilot" },
--           { name = "nvim_lsp" },
--           { name = "luasnip" },
--           { name = "buffer" },
--           { name = "path" },
--         }),
--       })
--     end,
--   },
--
--   -- copilot-cmp
--   {
--     "zbirenbaum/copilot-cmp",
--     dependencies = {
--       "zbirenbaum/copilot.lua",
--     },
--   },
-- }
