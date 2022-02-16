local local_package_path = "./?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"
package.path = package.path..';'..local_package_path

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- fennel {{{
  use 'bakpakin/fennel.vim'  -- syntax
  use 'jaawerth/fennel-nvim' -- native fennel support
  use 'Olical/conjure'       -- interactive environment
  use 'Olical/nvim-local-fennel'
  use {'Olical/aniseed', vim.cmd [[let g:aniseed#env = v:true]]} -- macro
  use 'tsbohc/zest.nvim' -- vim-specific macro
  -- }}}

  use_rocks {'fennel', 'luacheck'}
end)
