local util = require("wf.util")
local extend = util.extend
local rt = util.rt
local select = require("wf").select

local function _get_gmap()
  local keys = vim.api.nvim_get_keymap("n")
  local choices = {}
  for _, val in ipairs(keys) do
    if not string.match(val.lhs, "^<Plug>") then
      local lhs = string.gsub(val.lhs, " ", "<Space>")
      choices[lhs] = val.desc or val.rhs
    end
  end
  return choices
end

local function _get_bmap(buf)
  local keys = vim.api.nvim_buf_get_keymap(buf, "n")
  local choices = {}
  for _, val in ipairs(keys) do
    if not string.match(val.lhs, "^<Plug>") then
      local lhs = string.gsub(val.lhs, " ", "<Space>")
      choices[lhs] = val.desc or val.lhs .. " [buf]" --or val.rhs
    end
  end
  return choices
end

local function which_key(text_insert_in_advance)
  local core = function()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local g = _get_gmap()
    local b = _get_bmap(buf)
    local choices = extend(g, b)
    select(choices, {
      prompt = "> ",
      text_insert_in_advance = text_insert_in_advance or "",
      key_group_dict = vim.fn.luaeval("_G.__kaza.prefix"),
    }, function(_, lhs)
      if win == vim.api.nvim_get_current_win() and buf == vim.api.nvim_get_current_buf() then
        if vim.fn.mode() == "i" then
          vim.api.nvim_feedkeys(rt("<Esc>"), "n", false)
          vim.api.nvim_feedkeys(rt(lhs), "t", false)
        end
      end
    end)
  end
  return core
end

return which_key
