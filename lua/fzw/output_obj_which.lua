local static = require("fzw.static")
local prefix_size = static.prefix_size
local ns_output_obj = vim.api.nvim_create_namespace("ns_output_obj")
local M = {
  hls = {},
}
function M.add(self, buf, line, list, prefix_size)
  local index = prefix_size
  local text = ""
  for _, v in ipairs(list) do
    local text_len = vim.fn.strdisplaywidth(v[1])
    table.insert(self.hls, { buf, ns_output_obj, v[2], line, index, index + text_len })
    index = index + text_len
    text = text .. v[1]
  end
  return text
end

function M.place(self, buf)
  vim.api.nvim_buf_clear_namespace(buf, ns_output_obj, 0, -1)
  for _, v in ipairs(self.hls) do
    vim.api.nvim_buf_add_highlight(unpack(v))
  end
  self.hls = {}
end

function M.clear(self, buf)
  vim.api.nvim_buf_clear_namespace(buf, ns_output_obj, 0, -1)
  self.hls = {}
end

return M
