local static = require("wf.static")
local full_name = static.full_name
local row_offset = static.row_offset
local gen_obj = require("wf.common").gen_obj

local function output_obj_gen(prefix_size, opts)
  local style = opts.style
  local buf, win = gen_obj(row_offset() + style.input_win_row_offset + style.input_win_row_offset, opts)
  vim.api.nvim_buf_set_option(buf, "filetype", full_name .. "output")
  local wcnf = vim.api.nvim_win_get_config(win)
  vim.api.nvim_win_set_config(
    win,
    vim.fn.extend(
      wcnf,
      { border = style.borderchars.top, title_pos = "center", title = style.borderchars.top[2] }
    -- (function()
    --     if opts.title ~= nil then
    --       return { {opts.title,"WFTitleOutput"} }
    --     else
    --       return  style.borderchars.top[2]
    --     end
    -- end)()}
    )
  )
  -- U+2420 ␠ SYMBOL FOR SPACE
  -- U+2422 ␢ BLANK SYMBOL
  -- U+2423 ␣ OPEN BOX
  -- U+23B5 ⎵ BOTTOM SQUARE BRACKET
  -- U+23B6 ⎶ BOTTOM SQUARE BRACKET OVER TOP SQUARE BRACKET
  -- vim.cmd([[syntax match WFKeys "\%(^\s\)\@<=.\{]]..tostring(prefix_size).. [[}"]])
  vim.cmd([[syntax match WFKeys "\%(^\s\)\@<=]] .. string.rep(".", prefix_size) .. [[" contains=WFHead,WFKey]])
  vim.cmd("hi link WFKeys WFWhichRem")
  vim.cmd([[syntax match WFHead "\%(^\s\)\@<=." contained]])
  vim.cmd("hi link WFHead WFWhich")

  vim.cmd([[syntax match WFKey "\%(^\s\)\@<=<[0-9a-zA-Z\-@]\+>" contained]])
  vim.cmd("hi link WFKey WFWhich")

  vim.fn.matchadd("WFA", [[\%(^.\{]] .. tostring(prefix_size + 2) .. [[}\)\@<=.]], 5, -1) -- vim.cmd("hi Conceal guifg=" .. fg_rem)
  vim.cmd("hi link WFA WFSeparator")

  -- vim.fn.matchadd("Conceal", [[\%(^\s\)\@<=\s]], 5, -1, { conceal = "␠", window = win })
  -- vim.cmd("hi! link Conceal Identifier")
  return { buf = buf, win = win }
end

local function _update_output_obj(obj, choices, lines, row_offset)
  vim.api.nvim_buf_set_option(obj.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(obj.buf, 0, -1, true, choices)
  local cnf = vim.api.nvim_win_get_config(obj.win)
  local height = vim.api.nvim_buf_line_count(obj.buf)
  local row = lines - height - row_offset - 1
  local top_margin = 4
  if height > lines - row_offset + top_margin then
    height = lines - row_offset - 1 - top_margin
    row = 0 + top_margin
  end

  vim.api.nvim_win_set_config(obj.win, vim.fn.extend(cnf, { height = height, row = row, title_pos = "center" }))
  vim.api.nvim_buf_set_option(obj.buf, "modifiable", false)
end

return { _update_output_obj = _update_output_obj, output_obj_gen = output_obj_gen }
