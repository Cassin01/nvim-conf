local select = require("wf").select

local function mark(opts)
  local function _mark()
    local _opts = {
      title = "Mark",
      behavior = {
        skip_front_duplication = true,
        skip_back_duplication = true,
      },
    }
    opts = opts or {}
    for k, v in pairs(opts) do
      _opts[k] = v
    end
    local mlist = vim.fn.getmarklist()
    local minfo = {}
    local choice = {}
    for _, m in ipairs(mlist) do
      minfo[m.file] = m
      choice[m.file] = m.file .. ":" .. m.pos[2]
    end
    local win = vim.api.nvim_get_current_win()
    if table.maxn(mlist) == 0 then
      vim.api.nvim_echo({
          {"No buffers to switch to.", "ErrorMsg"}, {" @wf.builtin.buffer", "Comment"}
        }, false, {})
      return
    end
    select(choice, _opts, function(_, lhs)
      local pos = minfo[lhs].pos
      vim.api.nvim_win_set_buf(win, pos[1])
      vim.api.nvim_win_set_cursor(win, {pos[2], pos[3]})
    end)
  end

  return _mark
end

return mark
