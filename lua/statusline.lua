(function()
  -- このファイルが最初に require されたときのみ実行される
  local set_hl = vim.api.nvim_set_hl
  local bg_color = '#262626'
  local fg_color = '#999999'
  -- ハイライトの設定。Statusline はアクティブ StatuslineNC は非アクティブ
  set_hl(0, 'Statusline', { fg = fg_color, bg = bg_color })
  set_hl(0, 'StatuslineNC', { fg = '#444444', bg = '#181818' })
  set_hl(0, 'StatuslineNormalAccent', { fg = fg_color, bold = true, bg = '#333333' })
  set_hl(0, 'StatuslineInsertAccent', { fg = fg_color, bold = true, bg = '#555555' })
  set_hl(0, 'StatuslineReplaceAccent', { fg = fg_color, bold = true, bg = '#666b10' })
  set_hl(0, 'StatuslineConfirmAccent', { fg = fg_color, bold = true, bg = '#83adad' })
  set_hl(0, 'StatuslineTerminalAccent', { fg = fg_color, bold = true, bg = '#555555' })
  set_hl(0, 'StatuslineMiscAccent', { fg = fg_color, bold = true, bg = '#666b10' })
  set_hl(0, 'StatuslineDiagnosticERROR', { fg = '#FF0000', bold = true, bg = bg_color })
  set_hl(0, 'StatuslineDiagnosticWARN', { fg = '#FFAF00', bold = true, bg = bg_color })
end)()

local mode_name_table = {
  n = 'Normal',
  no = 'N·Operator Pending',
  v = 'Visual',
  V = 'V·Line',
  ['^V'] = 'V·Block',
  s = 'Select',
  S = 'S·Line',
  ['^S'] = 'S·Block',
  i = 'Insert',
  ic = 'Insert',
  R = 'Replace',
  Rv = 'V·Replace',
  c = 'Command',
  cv = 'Vim Ex',
  ce = 'Ex',
  r = 'Prompt',
  rm = 'More',
  ['r?'] = 'Confirm',
  ['!'] = 'Shell',
  t = 'Terminal',
}
local mode_color_table = {
  ['n'] = 'StatuslineNormalAccent',
  ['i'] = 'StatuslineInsertAccent',
  ['ic'] = 'StatuslineInsertAccent',
  ['R'] = 'StatuslineReplaceAccent',
  ['t'] = 'StatuslineTerminalAccent',
}

local function get_paste()
  return vim.o.paste and ' PASTE ' or ''
end

local function get_readonly_space()
  return ((vim.o.paste and vim.bo.readonly) and ' ' or '') and '%r' .. (vim.bo.readonly and ' ' or '')
end

local function get_encoding()
  return vim.o.fenc or vim.o.enc
end

local function get_fileformat()
  return vim.o.ff
end

local ft_table = {
  ['javascript'] = 'js',
  ['typescript'] = 'ts'
}
local function get_filetype()
  local ft = vim.o.ft
  return (not ft or ft == '') and '' or (ft_table[ft] or ft) .. '|'
end

local function get_filename()
  return '%f %m' .. get_paste() .. get_readonly_space()
end

-- エラーかワーニングがあったら '%#StatuslineDiagnosticERROR#1%*' の様に返す。
local function get_diagnostic()
  local d = {}
  for _, v in pairs({ 'ERROR', 'WARN' }) do
    local t = vim.diagnostic.get(0, { severity = vim.diagnostic.severity[v] })
    if t ~= nil and #t > 0 then
      table.insert(d, '%#StatuslineDiagnostic' .. v .. '#' .. tostring(#t) .. '%*')
    end
  end
  return table.concat(d, ' ')
end
-- アクティブウィンドウのステータスライン
local function get_active()
  return string.format([[%s %s %%= %%< %s]],
    get_filename(),
    get_diagnostic(),
  )
end
-- 非アクティブウィンドウのステータスライン
local function get_inactive()
  return ' %f%=%l/%L'
end
return { get_active = get_active, get_inactive = get_inactive }
