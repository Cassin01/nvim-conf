local gen_obj = require("wf.common").gen_obj
local row_offset = require("wf.static").row_offset

local function input_obj_gen(style)
  local buf, win = gen_obj(row_offset(), style)
  local wcnf = vim.api.nvim_win_get_config(win)
  vim.api.nvim_win_set_config(win, vim.fn.extend(wcnf, { title_pos = "center", title = style.borderchars.center[2] }))
  return { buf = buf, win = win, name = " Which Key "}
end

return { input_obj_gen = input_obj_gen }
