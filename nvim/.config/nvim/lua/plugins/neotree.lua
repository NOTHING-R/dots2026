return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    window = {
      width = 30,
      mappings = {
        ["h"] = "navigate_up",
        ["<bs>"] = "navigate_up",
        ["l"] = "open",
        ["<cr>"] = "open",
        ["H"] = "toggle_hidden",
        ["."] = "set_root",

        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["<C-r>"] = "clear_clipboard",

        ["c"] = "copy",
        ["m"] = "move",

        ["a"] = "add",
        ["A"] = "add_directory",
      },
    },

    filesystem = {
      bind_to_cwd = false, -- don't follow nvim's cwd changes
      hijack_netrw_behavior = "open_current", -- `nvim .` opens explorer
      follow_current_file = {
        enabled = true, -- highlight active file in tree
        leave_dirs_open = true, -- don't collapse parent folders
      },
      use_libuv_file_watcher = true,
    },

    enable_normal_mode_for_inputs = false,
  },

  config = function(_, opts)
    -- Lock the project root the moment nvim starts.
    -- Store it in vim.g so it never changes even if cwd drifts.
    vim.g.neotree_root_dir = vim.fn.getcwd()

    require("neo-tree").setup(opts)

    -- <leader>e always goes back to the folder you opened nvim from
    vim.keymap.set("n", "<leader>e", function()
      require("neo-tree.command").execute({
        toggle = true,
        source = "filesystem",
        position = "left",
        dir = vim.g.neotree_root_dir,
      })
    end, { desc = "Explorer (project root)" })

    -- When nvim is opened with a directory (e.g. `nvim .` or `nvim ~/myapp`),
    -- auto-open the explorer for that exact directory — just like VS Code.
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        local arg = vim.fn.argv(0)
        if arg and arg ~= "" and vim.fn.isdirectory(arg) == 1 then
          vim.g.neotree_root_dir = vim.fn.fnamemodify(arg, ":p")
          vim.defer_fn(function()
            require("neo-tree.command").execute({
              source = "filesystem",
              position = "left",
              dir = vim.g.neotree_root_dir,
            })
          end, 100)
        end
      end,
    })
  end,
}
