local function open_win(buf, height, row_offset)
  local conf_ = {
    col = 0,
    relative = "editor",
    anchor = "NW",
    style = "minimal",
    border = "rounded",
  }
  local conf = vim.fn.extend(
    conf_,
    { height = height, row = vim.o.lines - height - row_offset - 1, width = vim.o.columns - conf_.col }
  )
  return vim.api.nvim_open_win(buf, true, conf)
end

local function gen_obj(row_offset)
  local buf = vim.api.nvim_create_buf(false, true)
  local height = vim.api.nvim_buf_line_count(buf)
  local win = open_win(buf, height, row_offset)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  return buf, win
end

return { gen_obj = gen_obj }
