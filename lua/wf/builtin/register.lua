local select = require("wf").select
local registers = [[*+"-:.%/#=_abcdefghijklmnopqrstuvwxyz0123456789]]
local labels = {
  ['"'] = "last deleted, changed, or yanked content",
  ["0"] = "last yank",
  ["-"] = "deleted or changed content smaller than one line",
  ["."] = "last inserted text",
  ["%"] = "name of the current file",
  [":"] = "most recent executed command",
  ["#"] = "alternate buffer",
  ["="] = "result of an expression",
  ["+"] = "synchronized with the system clipboard",
  ["*"] = "synchronized with the selection clipboard",
  ["_"] = "black hole",
  ["/"] = "last search pattern",
}
local function register(opts)
  local function _register()
    local choices = {}
    for i = 1, #registers, 1 do
      local key = registers:sub(i, i)
      local ok, value = pcall(vim.fn.getreg, key, 1)
      if ok then
        value = vim.fn.substitute(value, "[[:cntrl:]]", "", "g")
        value = vim.fn.substitute(value, "\n", "", "g")
        if #value > 0 then
          choices[key] = (labels[key] or "") .. " " .. value
        end
      end
    end

    local _opts = {
      title = "Registers",
      output_obj_which_mode_desc_format = function(c)
        return { { (labels[c.key] or "") .. " ", "WFGroup" }, { c.text, "WFWhichDesc" } }
      end,
      prefix_size = 1,
    }
    opts = opts or {}
    for k, v in pairs(opts) do
      _opts[k] = v
    end
    select(choices, _opts, function(_, lhs)
      local cmd = [[normal! "]] .. lhs .. "p"
      vim.cmd(cmd)
    end)
  end
  return _register
end

return register
