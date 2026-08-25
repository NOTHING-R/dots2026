-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.toggles")
require("config.orgextra")
require("config.markdown")

-- This is for vscode-neovim extension, which allows you to use Neovim as the editor in VS Code. It provides a more native Neovim experience within VS Code, including better performance and compatibility with Neovim plugins. The code below sets up key mappings for navigating folds and toggling them using the Tab key when running inside VS Code.
if vim.g.vscode then
  local vscode = require("vscode")

  -- j/k skip over folds without opening them
  local function mapMove(key, direction)
    vim.keymap.set({ "n", "x" }, key, function()
      local count = vim.v.count
      vscode.action("cursorMove", {
        args = {
          {
            to = direction,
            by = count > 0 and "line" or "wrappedLine",
            value = count > 0 and count or 1,
          },
        },
      })
    end, { silent = true, noremap = true })
  end

  mapMove("j", "down")
  mapMove("k", "up")

  -- Tab to toggle fold (your existing one)
  vim.keymap.set("n", "<Tab>", function()
    vscode.call("editor.toggleFold")
  end, { desc = "Toggle fold" })
end
