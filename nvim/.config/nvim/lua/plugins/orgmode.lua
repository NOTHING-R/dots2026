return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/inbox.org",
        org_hide_emphasis_markers = true,
        org_startup_folded = "showeverything",
        -- org_startup_folded = "content",
        org_startup_indented = true,
        org_auto_indent = false,
        org_adapt_indentation = false,
        org_ellipsis = " ▾",
        org_hide_leading_stars = true,
        org_todo_keywords = {
          "TODO(t)",
          "INPROGRESS(i)",
          "WAITING(w)",
          "NEXT(n)",
          "|",
          "DONE(d)",
          "CANCELLED(c)",
        },
        org_todo_keyword_faces = {
          TODO = ":foreground #f7768e :weight bold",
          NEXT = ":foreground #ff9e64 :weight bold",
          INPROGRESS = ":foreground #e0af68 :weight bold",
          WAITING = ":foreground #9ece6a",
          DONE = ":foreground #565f89 :strike-through t",
          CANCELLED = ":foreground #565f89 :strike-through t",
        },
        org_agenda_span = "week",
        org_agenda_start_on_weekday = 6,
        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,
        org_deadline_warning_days = 3,
        org_priority_highest = "A",
        org_priority_default = "B",
        org_priority_lowest = "C",
        org_capture_templates = {
          t = {
            description = "Task",
            template = "* TODO %?\n  SCHEDULED: %T",
            -- target = "~/orgfiles/inbox.org",
          },
          q = {
            description = "Quick task (no date)",
            template = "* TODO %?",
            -- target = "~/orgfiles/inbox.org",
          },
          d = {
            description = "Task with DEADLINE",
            template = "* TODO %?\n  DEADLINE: %^{Deadline}T",
            -- target = "~/orgfiles/inbox.org",
          },
          n = {
            description = "Note",
            template = "* %?\n  %T",
            -- target = "~/orgfiles/notes.org",
          },
          j = {
            description = "Journal",
            template = "* %<%Y-%m-%d %A>\n** %?\n",
            -- target = "~/orgfiles/journal.org",
            datetree = true,
          },
          w = {
            description = "Web/Resource",
            template = "* %?\n  %T",
            target = "~/orgfiles/resources.org",
          },
        },
        org_src_block = { indent = true },
        org_structure_template_alist = {
          s = "#+BEGIN_SRC ?\n\n#+END_SRC",
          e = "#+BEGIN_EXAMPLE\n\n#+END_EXAMPLE",
          q = "#+BEGIN_QUOTE\n\n#+END_QUOTE",
          v = "#+BEGIN_VERSE\n\n#+END_VERSE",
          c = "#+BEGIN_CENTER\n\n#+END_CENTER",
          l = "#+BEGIN_EXPORT latex\n\n#+END_EXPORT",
        },
      })

      pcall(require("telescope").load_extension, "orgmode")
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

-- old config
-- return {
--   -- Main Org Mode Plugin
--   {
--     "nvim-orgmode/orgmode",
--     event = "VeryLazy",
--     ft = { "org" },
--     dependencies = { "nvim-treesitter/nvim-treesitter" },
--     config = function()
--       require("orgmode").setup({
--         org_agenda_files = "~/orgfiles/**/*",
--         org_default_notes_file = "~/orgfiles/refile.org",
--
--         -- Nice defaults (recommended)
--         org_hide_emphasis_markers = true,
--         org_startup_folded = "showeverything",
--         org_startup_indented = true, -- This is the line for Emacs-like virtual indent
--         -- Fix: Pressing Enter after a heading does NOT auto-insert another *
--         org_auto_indent = false,
--         -- Extra safety: Disable continuing comment/heading on new line
--         org_adapt_indentation = false,
--
--         org_todo_keywords = { "TODO(t)", "INPROGRESS(i)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
--
--         -- Better code block behavior
--         org_src_block = {
--           indent = true,
--         },
--
--         -- === CUSTOM ZOLA TEMPLATES (fixed) ===
--         org_structure_template_alist = {
--           s = "#+BEGIN_SRC ?\n\n#+END_SRC",
--           e = "#+BEGIN_EXAMPLE\n\n#+END_EXAMPLE",
--           q = "#+BEGIN_QUOTE\n\n#+END_QUOTE",
--           v = "#+BEGIN_VERSE\n\n#+END_VERSE",
--           c = "#+BEGIN_CENTER\n\n#+END_CENTER",
--           l = "#+BEGIN_EXPORT latex\n\n#+END_EXPORT",
--         },
--       })
--
--       -- Optional: Experimental Org LSP
--       vim.lsp.enable("org")
--     end,
--   },
--
--   -- Pretty bullets (◉ ○ ✸ etc.)
--   {
--     "nvim-orgmode/org-bullets.nvim",
--     ft = { "org" },
--     config = function()
--       require("org-bullets").setup()
--     end,
--   },
-- }
