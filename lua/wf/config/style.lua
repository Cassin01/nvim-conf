local M = {}
function M.new(theme)
  local themes = {
    default = {
      width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.5),
      border = "rounded",
      borderchars = {
        top = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        center = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        bottom = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      },
      icons = {
        separator = "➜", -- symbol used between a key and it's label
      },
      input_win_row_offset = 3, -- shift up output-window's row with input-window's height
    },
    space = {
      width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.5),
      border = "rounded",
      borderchars = {
        top = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        center = { "╭", "─", "╮", "│", "┤", "─", "├", "│" },
        bottom = { "", "", "", "│", "╯", "─", "╰", "│" },
      },
      icons = {
        separator = "➜", -- symbol used between a key and it's label
      },
      input_win_row_offset = 3, -- shift up output-window's row with input-window's height
    },
    chad = {
      width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.5),
      border = "solid",
      borderchars = {
        top = { " ", " ", " ", " ", " ", " ", " ", " " },
        center = { " ", " ", " ", " ", " ", " ", " ", " " },
        bottom = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
      icons = {
        separator = "   ", -- symbol used between a key and it's label (strdisplaywidth = 3)
      },
      input_win_row_offset = 3, -- shift up output-window's row with input-window's height
    },
  }
  return themes[theme] or themes["default"]
end

return M
