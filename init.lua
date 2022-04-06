local fn = vim.fn

local preinstall_list = {
  packer = {author = 'wbthomason', repo = 'packer.nvim'},
  hotpot = {author = 'rktjmp', repo = 'hotpot.nvim'},
  impatient = {author = 'lewis6991', repo = 'impatient.nvim'},
}

local preinstall_path = fn.stdpath 'data' .. '/site/pack/packer/start'

local init_install = false

for _, info in pairs(preinstall_list) do
  local plugin_path = preinstall_path .. info.repo
  if fn.empty(fn.glob(plugin_path)) > 0 then
    print("Could not find ", info.repo, ", cloning new copy to", plugin_path)
    local repo_path = 'https://github.com/' .. info.author .. '/' .. info.repo
    vim.fn.system({'git', 'clone', repo_path, '--depth', '1', plugin_path})
    init_install = true
  end
end

if init_install then
  require('impatient')
  require 'hotpot'
  require('init')
  require('packer').install()
  print("Rerun neovim")
end

require('impatient')
require('hotpot')
require('init')

-- Reference:
-- [6cdh](https://github.com/6cdh/dotfiles/blob/main/editor/nvim/init.lua)
