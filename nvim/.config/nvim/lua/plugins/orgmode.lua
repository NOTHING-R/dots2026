return {
  -- Main Org Mode Plugin
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/refile.org",

        -- Nice defaults (recommended)
        org_hide_emphasis_markers = true,
        org_startup_folded = "showeverything",
        org_startup_indented = true, -- This is the line for Emacs-like virtual indent
        -- Fix: Pressing Enter after a heading does NOT auto-insert another *
        org_auto_indent = false,
        -- Extra safety: Disable continuing comment/heading on new line
        org_adapt_indentation = false,

        org_todo_keywords = { "TODO(t)", "INPROGRESS(i)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },

        -- Better code block behavior
        org_src_block = {
          indent = true,
        },

        -- === CUSTOM ZOLA TEMPLATES (fixed) ===
        org_structure_template_alist = {
          s = "#+BEGIN_SRC ?\n\n#+END_SRC",
          e = "#+BEGIN_EXAMPLE\n\n#+END_EXAMPLE",
          q = "#+BEGIN_QUOTE\n\n#+END_QUOTE",
          v = "#+BEGIN_VERSE\n\n#+END_VERSE",
          c = "#+BEGIN_CENTER\n\n#+END_CENTER",
          l = "#+BEGIN_EXPORT latex\n\n#+END_EXPORT",
        },
      })

      -- Optional: Experimental Org LSP
      vim.lsp.enable("org")
    end,
  },

  -- Pretty bullets (◉ ○ ✸ etc.)
  {
    "nvim-orgmode/org-bullets.nvim",
    ft = { "org" },
    config = function()
      require("org-bullets").setup()
    end,
  },
}
