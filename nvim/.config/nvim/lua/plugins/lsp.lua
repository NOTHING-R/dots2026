return {

  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = true,
      },

      inlay_hints = { enabled = false },
      codelens = { enabled = false },

      servers = {
        -- copilot.lua only works with its own copilot lsp server
        -- HTML (only .html files)
        ts_ls = {
          enabled = false,
        },
        html = {
          filetypes = { "html" },
        },
        -- Emmet (HTML/CSS only, never jsx/js)
        emmet_language_server = {
          filetypes = { "html", "css", "scss", "sass", "less" },
        },

        -- CSS + SCSS + Less
        cssls = {
          filetypes = { "css", "scss", "less" },
        },

        -- Tailwind (html, jsx, tsx, js, ts, css)
        tailwindcss = {
          filetypes = {
            "html",
            "css",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },

        -- JS / TS / React / JSX / TSX (vtsls is the modern tsserver)
        -- vtsls = {
        --   filetypes = {
        --     "javascript",
        --     "javascriptreact",
        --     "typescript",
        --     "typescriptreact",
        --   },
        --   settings = {
        --     typescript = {
        --       preferences = { importModuleSpecifier = "relative" },
        --     },
        --     javascript = {
        --       preferences = { importModuleSpecifier = "relative" },
        --     },
        --   },
        -- },

        vtsls = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
          settings = {
            typescript = {
              preferences = { importModuleSpecifier = "relative" },
              suggest = { completeFunctionCalls = false },
            },
            javascript = {
              preferences = { importModuleSpecifier = "relative" },
            },
            vtsls = {
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                  entriesLimit = 50,
                },
              },
            },
          },
        },

        -- Python
        pyright = {
          filetypes = { "python" },
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic", -- "off" | "basic" | "strict"
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },

        -- Markdown
        marksman = {
          filetypes = { "markdown" },
        },

        -- Lua (neovim config)
        lua_ls = {
          filetypes = { "lua" },
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                -- makes lua_ls aware of neovim globals like vim.*
                -- library = vim.api.nvim_get_runtime_file("", true),
                library = {
                  vim.fn.expand("$VIMRUNTIME/lua"),
                  vim.fn.stdpath("config") .. "/lua",
                },
              },
              diagnostics = {
                globals = { "vim" }, -- no "undefined global vim" warnings
              },
              telemetry = { enable = false },
            },
          },
        },
      },
    },
  },
}
