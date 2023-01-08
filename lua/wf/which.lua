local gen_obj = require("wf.common").gen_obj

local function input_obj_gen(output_obj, style)
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0)
  local buf, win = gen_obj(_row_offset, style)

  return { buf = buf, win = win }
end

return { input_obj_gen = input_obj_gen }
