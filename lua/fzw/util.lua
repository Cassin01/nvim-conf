local M = {}

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
  for c in str:gmatch"." do
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

function M.match_front(str, patt)
  if string.len(str) < string.len(patt) then
    return false
  end
  for i = 1, patt:len() do
    if string.sub(str, i, i) ~= string.sub(patt,i, i) then
      return false
    end
  end
  return true
end

return M
