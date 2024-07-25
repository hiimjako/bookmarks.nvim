local repo = require("bookmarks.repo")
local sign = require("bookmarks.sign")
local domain = require("bookmarks.bookmark")


local M = {}

---@param name string
---@param line_no number
function M.create_folder(name, line_no)
  local ctx = vim.b._bm_context.line_contexts[line_no]

  local bookmark_lists = repo.bookmark_list.read.find_all()
  for _, bookmark_list in ipairs(bookmark_lists) do
    if domain.bookmark_list.create_tree_folder(bookmark_list, ctx.id, name) then
      repo.bookmark_list.write.save(bookmark_list)
      break
    end
  end

  sign.refresh_tree()
end


---@param line_no number
function M.cut(line_no)
  local ctx = vim.b._bm_context.line_contexts[line_no]
  vim.b._bm_tree_cut = ctx.id
  vim.print("Cut: " .. ctx.id)
end


---@param line_no number
function M.paste(line_no)
  local ctx = vim.b._bm_context.line_contexts[line_no]
  if not vim.b._bm_tree_cut then
    return
  end
  local _cut_id = vim.b._bm_tree_cut
  vim.b._bm_tree_cut = nil
  vim.print("Paste: " .. ctx.id .. " from " .. _cut_id)

  local bookmark_lists = repo.bookmark_list.read.find_all()
  for _, bookmark_list in ipairs(bookmark_lists) do
    if domain.bookmark_list.tree_paste(bookmark_list, _cut_id, ctx.id) then
      repo.bookmark_list.write.save(bookmark_list)
      break
    end
  end

  sign.refresh_tree()
end

return M
