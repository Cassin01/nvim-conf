local util = require("wf.util")
local extend = util.extend
local rt = util.rt
local get_mode = util.get_mode
local select = require("wf").select
local full_name = require("wf.static").full_name

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
      choices[lhs] = val.desc or val.rhs .. " [buf]" --or val.rhs
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
    local mode = get_mode()
    local count = vim.api.nvim_get_vvar("count")
    opts = opts or {}
    local _opts = {
      title = "Which Key",
      text_insert_in_advance = "",
      key_group_dict = vim.fn.luaeval("_G.__kaza.prefix"),
    }
    for k, v in pairs(opts) do
      _opts[k] = v
    end
    _opts["text_insert_in_advance"] = string.gsub(_opts["text_insert_in_advance"], "<Leader>", vim.g["mapleader"] or [[\]])

    select(choices, _opts, function(_, lhs)
      if win == vim.api.nvim_get_current_win() and buf == vim.api.nvim_get_current_buf() then
        local current_mode = vim.fn.mode()
        if count and count ~= 0 then
          lhs = count .. lhs
        end

        if current_mode == "i" then
          -- feed CTRL-O again i called from CTRL-O
          if mode == "nii" or mode == "nir" or mode == "niv" or mode == "vs" then
            vim.api.nvim_feedkeys(rt("<C-O>"), "n", false)
          else
            vim.api.nvim_feedkeys(rt("<Esc>"), "n", false)
          end

          -- feed the keys with remap
          vim.api.nvim_feedkeys(rt(lhs), "m", false)
        elseif current_mode == "n" then
          if mode == "n" then
            vim.api.nvim_feedkeys(rt(lhs), "m", false)
          end
        else
          print("which-key: mode is not n or i")
        end
      end
    end)
  end
  return core
end

return which_key
