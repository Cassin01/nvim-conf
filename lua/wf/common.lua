local style = require("wf.style").new()
local function open_win(buf, height, row_offset, style)
  local conf_ = {
    -- col = 0,
    -- col = math.ceil(vim.o.columns * 0.6),
    width = style.width,
    -- width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.3),
    relative = "editor",
    anchor = "NW",
    style = "minimal",
    -- border = "shadow",
    -- border = {" ", " ", " ", " ", " ", " ", " ", " "},
    -- border = "none",
    border = "rounded",
    -- title = {
    --   {"T","TRed"}, {"i","TOrange"},{"t","TYellow"},
    --   {"i","TGreen"},{"l","TBlue"},{"e","TPurple"},
    -- },
    -- title_pos = "center"
  }
  local conf = vim.fn.extend(conf_, {
    height = height,
    row = vim.o.lines - height - row_offset - 1,
    -- width = vim.o.columns - conf_.col,
    col = vim.o.columns - conf_.width,
  })
  return vim.api.nvim_open_win(buf, true, conf)
end

local function gen_obj(row_offset)
  local buf = vim.api.nvim_create_buf(false, true)
  local height = vim.api.nvim_buf_line_count(buf)
  local win = open_win(buf, height, row_offset, style)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:Normal")
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "buflisted", false)
  return buf, win
end

return { gen_obj = gen_obj }
