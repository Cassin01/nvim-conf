vim.cmd [[packadd packer.nvim]]
vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]

return require('packer').startup(function()
 -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Simple plugins can be specified as strings
  use '9mm/vim-closer'

  use_rocks {'fennel', 'luacheck'}
end)
