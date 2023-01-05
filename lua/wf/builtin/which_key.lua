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
      local lhs = val.lhs
      lhs = string.gsub(lhs, " ", "<Space>")
      choices[lhs] = val.desc or val.lhs .. " [buf]" --or val.rhs
    end
  end
  return choices
end

local function which_key(opts)
  local core = function()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local g = _get_gmap()
    local b = _get_bmap(buf)
    local choices = extend(g, b)

    opts = opts or {}
    local _opts = {
      prompt = "> ",
      text_insert_in_advance = "",
      key_group_dict = vim.fn.luaeval("_G.__kaza.prefix"),
    }
    for k, v in pairs(opts) do
      _opts[k] = v
    end
    _opts["text_insert_in_advance"] = string.gsub(_opts["text_insert_in_advance"], "<Leader>", vim.g["mapleader"] or [[\]])

    select(choices, _opts, function(_, lhs)
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
