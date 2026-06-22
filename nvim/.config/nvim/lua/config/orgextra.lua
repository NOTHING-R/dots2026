-- Org → Markdown export for Zola (with TOML front matter)
vim.api.nvim_create_user_command("OrgExportZola", function()
  local org_file = vim.api.nvim_buf_get_name(0)
  if vim.fn.fnamemodify(org_file, ":e") ~= "org" then
    vim.notify("Not an .org file!", vim.log.levels.ERROR)
    return
  end

  local base = vim.fn.fnamemodify(org_file, ":t:r") -- filename without ext
  local dir = vim.fn.fnamemodify(org_file, ":h") -- same directory
  local out = dir .. "/" .. base .. ".md"
  local date = os.date("%Y-%m-%d")
  local author = vim.fn.system("git config user.name"):gsub("\n", "")
  if author == "" then
    author = "Author"
  end

  -- Read all lines of the org file
  local lines = vim.fn.readfile(org_file)
  local md_lines = {}

  -- Insert TOML front matter
  table.insert(md_lines, "+++")
  table.insert(md_lines, string.format('title = "%s"', base))
  table.insert(md_lines, string.format('date = "%s"', date))
  table.insert(md_lines, string.format('author = "%s"', author))
  table.insert(md_lines, "+++")
  table.insert(md_lines, "")

  -- Convert org lines to markdown (basic but covers most cases)
  for _, line in ipairs(lines) do
    -- Headings: * → #
    local heading = line:match("^(%*+)%s+(.*)")
    if heading then
      local level = #line:match("^%*+")
      local text = line:match("^%*+ (.*)")
      table.insert(md_lines, string.rep("#", level) .. " " .. text)

    -- Bold: *text* → **text**
    elseif line:match("%*[^%*]+%*") then
      table.insert(md_lines, (line:gsub("%*([^%*]+)%*", "**%1**")))

    -- Italic: /text/ → *text*
    elseif line:match("/[^/]+/") then
      table.insert(md_lines, (line:gsub("/([^/]+)/", "*%1*")))

    -- Code: ~text~ → `text`
    elseif line:match("~[^~]+~") then
      table.insert(md_lines, (line:gsub("~([^~]+)~", "`%1`")))

    -- Unordered list: - or + → -
    elseif line:match("^%s*[-+]%s+") then
      table.insert(md_lines, line)

    -- Ordered list: 1. stays the same
    elseif line:match("^%s*%d+%. ") then
      table.insert(md_lines, line)

    -- #+begin_src / #+end_src → fenced code block
    elseif line:lower():match("^#%+begin_src") then
      local lang = line:lower():match("^#%+begin_src%s+(%S*)") or ""
      table.insert(md_lines, "```" .. lang)
    elseif line:lower():match("^#%+end_src") then
      table.insert(md_lines, "```")

    -- Skip #+TITLE, #+AUTHOR, #+DATE etc. (already in front matter)
    elseif line:match("^#%+%u") then
      -- skip
    else
      table.insert(md_lines, line)
    end
  end

  vim.fn.writefile(md_lines, out)
  vim.notify("Exported → " .. out, vim.log.levels.INFO)
end, {})

-- === CUSTOM ZOLA INSERT FUNCTIONS (works in ANY file) ===
local function insert_zola_template(template_type)
  local templates = {
    y = [[#+BEGIN_EXPORT html
<iframe width="350" height="200"
 src="https://www.youtube.com/embed/"
 title="YouTube video player"
 frameborder="0"
 allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
 allowfullscreen>
</iframe>
#+END_EXPORT]],

    z = [[#+BEGIN_EXPORT html
<video controls width="100%">
 <source src="/videos/.mp4" type="video/mp4">
 Your browser does not support the video tag.
</video>
#+END_EXPORT]],

    j = [[#+BEGIN_EXPORT html
<img src="/folder/name" alt="IMAGE" width="300" height="220">
#+END_EXPORT]],
  }

  local snippet = templates[template_type]
  if not snippet then
    vim.notify("Unknown Zola template: " .. template_type, vim.log.levels.ERROR)
    return
  end

  -- Insert at cursor position
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, vim.split(snippet, "\n"))
  vim.notify("Inserted Zola " .. template_type .. " template", vim.log.levels.INFO)
end

-- Create user commands (you can use these anywhere)
vim.api.nvim_create_user_command("ZolaYouTube", function()
  insert_zola_template("y")
end, {})
vim.api.nvim_create_user_command("ZolaVideo", function()
  insert_zola_template("z")
end, {})
vim.api.nvim_create_user_command("ZolaImage", function()
  insert_zola_template("j")
end, {})

-- Optional: Keybindings (change <leader>z to whatever you like)
vim.keymap.set("n", "<leader>zy", function()
  insert_zola_template("y")
end, { desc = "Insert Zola YouTube" })
vim.keymap.set("n", "<leader>zv", function()
  insert_zola_template("z")
end, { desc = "Insert Zola Video" })
vim.keymap.set("n", "<leader>zj", function()
  insert_zola_template("j")
end, { desc = "Insert Zola Image" })
vim.keymap.set("n", "<leader>ze", "<cmd>OrgExportZola<CR>", {
  desc = "Export Org to Zola Markdown",
})
