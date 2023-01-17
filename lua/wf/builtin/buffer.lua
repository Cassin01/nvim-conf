local select = require("wf").select

local function get_active_buffers()
    local blist = vim.fn.getbufinfo({ bufloadled = 1,  buflisted = 1})
    local res = {}
    for _, b in ipairs(blist) do
      if vim.fn.empty(b.name) ~= 0 then -- or b.hidden ~= 0 then
        goto continue
      end
      res[b.bufnr] = b.name
      ::continue::
    end
    return res
end

local function buffer(opts)
  local function _buffer()
    local _opts = {
      title = "Buffer",
      behavior = {
        skip_front_duplication = true,
        skip_back_duplication = true,
      },
    }
    opts = opts or {}
    for k, v in pairs(opts) do
      _opts[k] = v
    end
    local blist = get_active_buffers()
    print(table.maxn(blist))
    if table.maxn(blist) == 0 then
      vim.api.nvim_echo({
          {"No buffers to switch to.", "ErrorMsg"}, {" @wf.builtin.buffer", "Comment"}
        }, false, {})
      return
    end
    select(blist, _opts, function(_, lhs)
      if vim.fn.bufexists(lhs) ~= 0 then
        vim.api.nvim_set_current_buf(lhs)
      end
    end)
  end

  return _buffer
end

return buffer
