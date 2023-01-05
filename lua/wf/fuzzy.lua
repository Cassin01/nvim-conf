local gen_obj = require("wf.common").gen_obj
local static = require("wf.static")
local _g = static._g
local input_win_row_offset = static.input_win_row_offset
local au = require("wf.util").au

local function input_obj_gen(output_obj, choices)
  local _row_offset = vim.o.cmdheight + (vim.o.laststatus > 0 and 1 or 0) + input_win_row_offset
  local buf, win = gen_obj(_row_offset)

  -- _update_output_obj(output_obj, choices, _lines, _row_offset + input_win_row_offset)
  au(_g, "BufEnter", function()
    local _, _ = pcall(function()
      -- turn off the completion
      require("cmp").setup.buffer({ enabled = false })
    end)
  end, { buffer = buf })

  return { buf = buf, win = win }
end

return { input_obj_gen = input_obj_gen }
