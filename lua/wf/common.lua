local function open_win(buf, height, row_offset, style)
  local conf_ = {
    width = style.width,
    relative = "editor",
    anchor = "NW",
    style = "minimal",
    border = style.border,
  }
  local conf = vim.fn.extend(conf_, {
    height = height,
    row = vim.o.lines - height - row_offset - 1,
    col = vim.o.columns - conf_.width,
  })
  return vim.api.nvim_open_win(buf, true, conf)
end

local function gen_obj(row_offset, style)
  local buf = vim.api.nvim_create_buf(false, true)
  local height = vim.api.nvim_buf_line_count(buf)
  local win = open_win(buf, height, row_offset, style)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:WFNormal,FloatBorder:WFFloatBorder")
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  return buf, win
end

return { gen_obj = gen_obj }
