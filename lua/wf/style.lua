local M = {}
function M.new()
  return {
    -- width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.5)
    -- width = vim.o.columns > 45 and 45 or math.ceil(vim.o.columns * 0.5)
    width = vim.o.columns
  }
end

return M
