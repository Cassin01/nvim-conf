local static = require("wf.static")
local plug_name = static.plug_name
local row_offset_ = static.row_offset
local gen_obj = require("wf.common").gen_obj
local ns_wf_output_obj_which = vim.api.nvim_create_namespace("wf_output_obj_which")

local function set_highlight(buf, lines, opts, endup_obj, which_obj)
  local prefix_size = opts.prefix_size
  vim.api.nvim_buf_clear_namespace(buf, ns_wf_output_obj_which, 0, -1)
  -- local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
  local heads = {}
  for l = 0, #lines - 1 do
    -- head
    local match_ = lines[l + 1]:sub(1, prefix_size + 1)
    local match = string.match(match_, "<[%u%l%d%-@]+>")
    table.insert(heads, match ~= nil and match or lines[l + 1]:sub(2, 2))
    local till = match ~= nil and #match or 1
    -- vim.api.nvim_buf_add_highlight(buf, ns_wf_output_obj_which, "WFWhich", l, 1, 1 + till)

    -- prefix
    vim.api.nvim_buf_add_highlight(buf, ns_wf_output_obj_which, "WFWhichRem", l, 1 + till, prefix_size + 1)

    -- separator
    vim.api.nvim_buf_add_highlight(buf, ns_wf_output_obj_which, "WFSeparator", l, prefix_size + 4, prefix_size + 5)
  end

  -- head
  if vim.api.nvim_get_current_buf() == which_obj.buf then
    for l, head in ipairs(heads) do
      local is_unique = (function()
        for j, head_ in ipairs(heads) do
          if l ~= j and head == head_ then
            return false
          end
        end
        return true
      end)()
      if is_unique and endup_obj[l]["type"] == "key" and opts.behavior.shortest_match then
        vim.api.nvim_buf_add_highlight(buf, ns_wf_output_obj_which, "WFWhichUnique", l - 1, 1, 1 + #head)
      else
        vim.api.nvim_buf_add_highlight(buf, ns_wf_output_obj_which, "WFWhich", l - 1, 1, 1 + #head)
      end
    end
  end
end

local function output_obj_gen(opts)
  local style = opts.style
  local buf, win = gen_obj(row_offset_() + style.input_win_row_offset + style.input_win_row_offset, opts)
  vim.api.nvim_buf_set_option(buf, "filetype", plug_name .. "output")
  local wcnf = vim.api.nvim_win_get_config(win)
  vim.api.nvim_win_set_config(
    win,
    vim.fn.extend(wcnf, { border = style.borderchars.top, title_pos = "center", title = style.borderchars.top[2] })
  )
  return { buf = buf, win = win }
end

local function _update_output_obj(obj, choices, lines, row_offset, opts, endup_obj, which_obj)
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
  set_highlight(obj.buf, choices, opts, endup_obj, which_obj)
  vim.api.nvim_buf_set_option(obj.buf, "modifiable", false)
end

return { _update_output_obj = _update_output_obj, output_obj_gen = output_obj_gen }
