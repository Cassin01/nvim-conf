local gen_obj = require("wf.common").gen_obj
local row_offset = require("wf.static").row_offset

local function input_obj_gen(style)
  local buf, win = gen_obj(row_offset(), style)

  return { buf = buf, win = win }
end

return { input_obj_gen = input_obj_gen }
