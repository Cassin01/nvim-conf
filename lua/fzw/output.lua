local static = require("fzw.static")
local full_name = static.full_name
local input_win_row_offset = static.input_win_row_offset -- shift up output-window's row with input-window's height
local gen_obj = require("fzw.common").gen_obj

local function output_obj_gen()
  local buf, win = gen_obj(vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset + input_win_row_offset)
  vim.api.nvim_buf_set_option(buf, "filetype", full_name .. "output")

  return { buf = buf, win = win }
end

local function _update_output_obj(obj, choices, lines, row_offset)
  vim.api.nvim_buf_set_lines(obj.buf, 0, -1, true, choices)
  local cnf = vim.api.nvim_win_get_config(obj.win)
  local height = vim.api.nvim_buf_line_count(obj.buf)
  local row = lines - height - row_offset - 1
  if height > lines - row_offset then
    height = lines - row_offset - 1
    row = 0
  end

  vim.api.nvim_win_set_config(obj.win, vim.fn.extend(cnf, { height = height, row = row }))
end

return { _update_output_obj = _update_output_obj, output_obj_gen = output_obj_gen }
