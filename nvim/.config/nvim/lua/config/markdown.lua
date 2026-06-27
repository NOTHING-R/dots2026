local function update_markdown_toc()
  local path = vim.fn.expand("%")
  local bufnr = 0
  vim.cmd("mkview")

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Strip existing TOC block if present (# Table of contents ... <!-- tocstop -->)
  local content_start = 1
  if lines[1] and lines[1]:match("^# Table of contents") then
    for i, line in ipairs(lines) do
      if line:match("<!%-%- tocstop %-%->") then
        -- skip blank line after tocstop if present
        content_start = i + 1
        if lines[content_start] and lines[content_start]:match("^%s*$") then
          content_start = content_start + 1
        end
        break
      end
    end
  end

  -- Get only the real content lines
  local content_lines = {}
  for i = content_start, #lines do
    table.insert(content_lines, lines[i])
  end

  -- Prepend <!-- toc --> so markdown-toc knows where to inject
  local with_marker = {}
  table.insert(with_marker, "<!-- toc -->")
  for _, line in ipairs(content_lines) do
    table.insert(with_marker, line)
  end

  -- Write to buffer and save so markdown-toc can read the file
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, with_marker)
  vim.cmd("silent write")

  -- Run markdown-toc — it fills in between <!-- toc --> and <!-- tocstop -->
  local result = vim.fn.system('markdown-toc --bullets "-" -i ' .. vim.fn.shellescape(path))
  if vim.v.shell_error ~= 0 then
    vim.notify("markdown-toc failed: " .. result, vim.log.levels.ERROR)
    vim.cmd("loadview")
    return
  end

  -- Reload file after markdown-toc edited it
  vim.cmd("edit!")
  local new_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Find <!-- toc --> ... <!-- tocstop --> block
  local toc_start, toc_end = nil, nil
  for i, line in ipairs(new_lines) do
    if line:match("^<!%-%- toc %-%->%s*$") then
      toc_start = i
    end
    if line:match("^<!%-%- tocstop %-%->%s*$") then
      toc_end = i
    end
  end

  if not toc_start or not toc_end then
    vim.notify("TOC generation failed — no headings found in file?", vim.log.levels.ERROR)
    vim.cmd("loadview")
    return
  end

  -- Extract the generated TOC links
  local toc_links = {}
  for i = toc_start + 1, toc_end - 1 do
    table.insert(toc_links, new_lines[i])
  end

  -- Get content after <!-- tocstop -->
  local content_after = {}
  for i = toc_end + 1, #new_lines do
    table.insert(content_after, new_lines[i])
  end
  -- Remove leading blank line if present
  if content_after[1] and content_after[1]:match("^%s*$") then
    table.remove(content_after, 1)
  end

  -- Build final file
  local final = {}
  table.insert(final, "# Table of contents")
  table.insert(final, "<!-- toc -->")
  for _, link in ipairs(toc_links) do
    table.insert(final, link)
  end
  table.insert(final, "<!-- tocstop -->")
  table.insert(final, "")
  for _, line in ipairs(content_after) do
    table.insert(final, line)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, final)
  vim.cmd("silent write")
  vim.cmd("edit!")
  vim.notify("TOC updated", vim.log.levels.INFO)
  vim.cmd("loadview")
end

vim.keymap.set("n", "<leader>mtt", update_markdown_toc, { desc = "Insert/update Markdown TOC at top" })

-- local function update_markdown_toc(heading2, heading3)
--   local path = vim.fn.expand("%") -- Expands the current file name to a full path
--   local bufnr = 0 -- The current buffer number, 0 references the current active buffer
--   -- Save the current view
--   -- If I don't do this, my folds are lost when I run this keymap
--   vim.cmd("mkview")
--   -- Retrieves all lines from the current buffer
--   local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
--   local toc_exists = false -- Flag to check if TOC marker exists
--   local frontmatter_end = 0 -- To store the end line number of frontmatter
--   -- Check for frontmatter and TOC marker
--   for i, line in ipairs(lines) do
--     if i == 1 and line:match("^---$") then
--       -- Frontmatter start detected, now find the end
--       for j = i + 1, #lines do
--         if lines[j]:match("^---$") then
--           frontmatter_end = j
--           break
--         end
--       end
--     end
--     -- Checks for the TOC marker
--     if line:match("^%s*<!%-%-%s*toc%s*%-%->%s*$") then
--       toc_exists = true
--       break
--     end
--   end
--   -- Inserts H2 and H3 headings and <!-- toc --> at the appropriate position
--   if not toc_exists then
--     local insertion_line = 1 -- Default insertion point after first line
--     if frontmatter_end > 0 then
--       -- Find H1 after frontmatter
--       for i = frontmatter_end + 1, #lines do
--         if lines[i]:match("^#%s+") then
--           insertion_line = i + 1
--           break
--         end
--       end
--     else
--       -- Find H1 from the beginning
--       for i, line in ipairs(lines) do
--         if line:match("^#%s+") then
--           insertion_line = i + 1
--           break
--         end
--       end
--     end
--     -- Insert the specified headings and <!-- toc --> without blank lines
--     -- Insert the TOC inside a H2 and H3 heading right below the main H1 at the top lamw25wmal
--     -- vim.api.nvim_buf_set_lines(bufnr, insertion_line, insertion_line, false, { heading2, heading3, "<!-- toc -->" })
--     vim.api.nvim_buf_set_lines(bufnr, insertion_line, insertion_line, false, { "", heading2, heading3, "<!-- toc -->" })
--   end
--   -- Silently save the file, in case TOC is being created for the first time
--   vim.cmd("silent write")
--   -- Silently run markdown-toc to update the TOC without displaying command output
--   -- vim.fn.system("markdown-toc -i " .. path)
--   -- I want my bulletpoints to be created only as "-" so passing that option as
--   -- an argument according to the docs
--   -- https://github.com/jonschlinkert/markdown-toc?tab=readme-ov-file#optionsbullets
--   vim.fn.system('markdown-toc --bullets "-" -i ' .. path)
--   vim.cmd("edit!") -- Reloads the file to reflect the changes made by markdown-toc
--   vim.cmd("silent write") -- Silently save the file
--   vim.notify("TOC updated and file saved", vim.log.levels.INFO)
--   vim.cmd("loadview")
-- end
--
-- -- HACK: Create table of contents in neovim with markdown-toc
-- -- https://youtu.be/BVyrXsZ_ViA
-- --
-- -- Keymap for English TOC
-- vim.keymap.set("n", "<leader>mtt", function()
--   update_markdown_toc("## Contents", "### Table of contents")
-- end, { desc = "[P]Insert/update Markdown TOC (English)" })
