local extend = require("wf.util").extend
local full_name = require("wf.static").full_name

-- @param ground string "fg" or "bg"
local function get_hl(tbl, name, ground)
  local _ground = vim.fn.synIDattr(vim.fn.hlID(name), ground)
  if _ground ~= "" then
    tbl[ground] = _ground
  end
  return tbl
end

local themes = {
  chad = {
    highlight = {
      WFNornal = "NormalFloat",
      WFComment = (function()
        local tbl = { default = true }
        tbl = get_hl(tbl, "Comment", "fg")
        tbl = get_hl(tbl, "NormalFloat", "bg")
        return tbl
      end)(),
      WFFloatBorder = (function()
        local tbl = { default = true }
        tbl = get_hl(tbl, "FloatBorder", "fg")
        tbl = get_hl(tbl, "NormalFloat", "bg")
        return tbl
      end)(),
      WFFloatBorderFocus = "Normal",
      WFWhichRem = "Comment",
      WFWhichOn = "Keyword",
      WFFuzzy = "String",
      WFFuzzyPrompt = "Error",
      WFFocus = "Normal",
      WFFreeze = "Comment",
      WFWhichObjCounter = "Comment",
      WFWhichDesc = "Normal",
      WFSeparator = "Comment",
      WFGroup = "Function",
      WFExpandable = "Type",
    },
  },
  default = {
    highlight = {
      WFNormal = "Normal",
      WFFloatBorder = "FloatBorder",
      WFFloatBorderFocus = "FloatBorder",
      WFComment = "Comment",
      WFWhichRem = "Comment",
      WFWhichOn = "Keyword",
      WFFuzzy = "String",
      WFFuzzyPrompt = "Error",
      WFFocus = "WFNormal",
      WFFreeze = "Comment",
      WFWhichObjCounter = "NonText",
      WFWhichDesc = "Normal",
      WFSeparator = "Comment",
      WFGroup = "Function",
      WFExpandable = "Type",
    },
  },
  space = {
    highlight = {
      WFFloatBorder = "FloatBorder",
      WFFloatBorderFocus = "FloatBorder",
      WFNormal = "Normal",
      WFComment = "Comment",
      WFWhichRem = "Comment",
      WFWhichOn = "Keyword",
      WFFuzzy = "String",
      WFFuzzyPrompt = "Error",
      WFFocus = "WFNormal",
      WFFreeze = "Comment",
      WFWhichObjCounter = "NonText",
      WFWhichDesc = "Normal",
      WFSeparator = "Comment",
      WFGroup = "Function",
      WFExpandable = "Type",
    },
  },
}

local function setup(opts)
  opts = opts or { theme = "chad" }
  opts.highlight = themes[opts.theme].highlight or opts.highlight

  for k, v in pairs(opts.highlight) do
    if type(v) == "string" then
      vim.api.nvim_set_hl(0, k, { default = true, link = v })
    elseif type(v) == "table" then
      vim.api.nvim_set_hl(0, k, v)
    end
  end
  vim.g[full_name .. "#theme"] = opts.theme
end

return { setup = setup }
