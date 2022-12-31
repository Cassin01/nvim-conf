local util = require("fzw.util")

local plug_name = "fz_witch"
local full_name = (function(hash)
  return plug_name .. hash
end)("309240")
local _g = util.aug(full_name)
local input_win_row_offset = 3 -- shift up output-window's row with input-window's height
local sign_group_prompt = full_name .. "prompt"
local sign_group_witch = full_name .. "which"

-- util
local function bmap(buf, mode, key, f, desc)
  util.bmap(buf, mode, key, f, "[" .. plug_name .. "] " .. desc)
end

return {
  plug_name = plug_name,
  full_name = full_name,
  _g = _g,
  input_win_row_offset = input_win_row_offset,
  bmap = bmap,
  sign_group_prompt = sign_group_prompt,
  sign_group_witch = sign_group_witch,
}
