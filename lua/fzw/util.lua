local M = {}

function M.array_reverse(x)
  local n, m = #x, #x / 2
  for i = 1, m do
    x[i], x[n - i + 1] = x[n - i + 1], x[i]
  end
  return x
end

function M.cmd(name, f, opt)
  opt = (opt or {})
  opt["force"] = true
  vim.api.nvim_create_user_command(name, f, opt)
end

function M.aug(group)
  vim.api.nvim_create_augroup(group, { clear = true })
end

function M.au(group, event, callback, opt_)
  local opt = vim.fn.extend(opt_ or {}, { callback = callback, group = group })
  vim.api.nvim_create_autocmd(event, opt)
end

function M.rt(str)
  return vim.api.nvim_replace_termcodes(str, true, false, true)
end

function M.bmap(buf, mode, key, f, desc)
  if type(mode) == "table" then
    for _, v in pairs(mode) do
      vim.api.nvim_buf_set_keymap(buf, v, key, "", { callback = f, noremap = true, silent = true, desc = desc })
    end
  elseif type(mode) == "string" then
    vim.api.nvim_buf_set_keymap(buf, mode, key, "", { callback = f, noremap = true, silent = true, desc = desc })
  end
end

function M.fill_spaces(str, len)
  local res = ""
  for c in str:gmatch(".") do
    if vim.fn.strdisplaywidth(res .. c) > len then
      break
    end
    res = res .. c
  end
  for _ = 1, len - vim.fn.strdisplaywidth(res) do
    res = res .. " "
  end
  return res
end

function M.match_from_front(str, patt)
  if string.len(str) < string.len(patt) then
    return false
  end
  for i = 1, patt:len() do
    if string.sub(str, i, i) ~= string.sub(patt, i, i) then
      return false
    end
  end
  return true
end

local function _escape(c)
  if c == [[\]] then
    return [[\\]]
  else
    return c
  end
end
function M.match_from_front_ignore_case(str, patt)
  if string.len(str) < string.len(patt) then
    return false
  end
  for i = 1, patt:len() do
    local c = string.sub(str, i, i)
    local p = string.sub(patt, i, i)
    if vim.api.nvim_eval( [["]] .. _escape(c) .. [[" ==? "]] .. _escape(p) .. [["]]) == 0 then
      return false
    end
  end
  return true
end

function M.match_from_tail(str, patt)
  if string.len(str) < string.len(patt) then
    return false
  end
  for i = 1, patt:len() do
    if string.sub(str, -i, -i) ~= string.sub(patt, -i, -i) then
      return false
    end
  end
  return true
end

function M.replace_nth(str, n, old, new)
  if n <= #str and str:sub(n, n) == old then
    return str:sub(1, n - 1) .. new .. str:sub(n + 1)
  end
  return str
end

return M
