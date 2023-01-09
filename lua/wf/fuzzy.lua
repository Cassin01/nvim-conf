local gen_obj = require("wf.common").gen_obj
local static = require("wf.static")
local row_offset = static.row_offset
local _g = static._g
-- local input_win_row_offset = static.input_win_row_offset
local au = require("wf.util").au

local function input_obj_gen(style)
  local _row_offset = row_offset() + style.input_win_row_offset
  local buf, win = gen_obj(_row_offset, style)

  -- _update_output_obj(output_obj, choices, _lines, _row_offset + input_win_row_offset)
  au(_g, "BufEnter", function()
    local _, _ = pcall(function()
      -- turn off the completion
      require("cmp").setup.buffer({ enabled = false })
    end)
  end, { buffer = buf })

  local wcnf = vim.api.nvim_win_get_config(win)
  vim.api.nvim_win_set_config(win, vim.fn.extend(wcnf, { title_pos = "left", title = style.borderchars.bottom[2] }))
  return { buf = buf, win = win, name = " Fuzzy Finder " }
end

return { input_obj_gen = input_obj_gen }
