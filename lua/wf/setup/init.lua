local extend = require("wf.util").extend

local themes = {
  chad = {
    highlight = {
      WFWhichRem = "Comment",
      WFWhichOn = "Keyword",
      WFFuzzy = "String",
      WFFuzzyPrompt = "Error",
      WFFreeze = "Comment",
      WFWhichObjCounter = "Function",
      WFWhichDesc = "Normal",
      WFSeparator = "Comment",
      WFGroup = "Function",
      WFExpandable = "Type",
    }
  },
  default = {
    highlight = {
      WFWhichRem = "Comment",
      WFWhichOn = "Keyword",
      WFFuzzy = "String",
      WFFuzzyPrompt = "Error",
      WFFreeze = "Comment",
      WFWhichObjCounter = "NonText",
      WFWhichDesc = "Normal",
      WFSeparator = "Comment",
      WFGroup = "Function",
      WFExpandable = "Type",
    }
  }
}

local function setup(opts)
  opts = opts or { theme = "chad" }
  opts.highlight = themes[opts.theme].highlight or opts.highlight

  for k, v in pairs(opts.highlight) do
    vim.api.nvim_set_hl(0, k, { default = true, link = v })
  end
end

return { setup = setup }
