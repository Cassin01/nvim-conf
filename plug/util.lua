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

return M
