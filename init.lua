--
--  ██╗███╗   ██╗██╗████████╗███████╗███╗   ██╗██╗
--  ██║████╗  ██║██║╚══██╔══╝██╔════╝████╗  ██║██║
--  ██║██╔██╗ ██║██║   ██║   █████╗  ██╔██╗ ██║██║
--  ██║██║╚██╗██║██║   ██║   ██╔══╝  ██║╚██╗██║██║
--  ██║██║ ╚████║██║   ██║██╗██║     ██║ ╚████║███████╗
--  ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝╚═╝     ╚═╝  ╚═══╝╚══════╝
--
--                 presented by
--
--               ╔═╗┌─┐┌─┐┌─┐┬┌┐┌
--               ║  ├─┤└─┐└─┐││││
--               ╚═╝┴ ┴└─┘└─┘┴┘└┘
--


vim.cmd([[let g:python3_host_prog="/Users/cassin/.pyenv/shims/python"]])
local hotpot_path = vim.fn.stdpath('data')..'/site/pack/packer/start/hotpot.nvim'
if vim.fn.empty(vim.fn.glob(hotpot_path)) > 0 then
  print("Could not find hotpot.nvim, cloning new copy to", hotpot_path)
  vim.fn.system({'git', 'clone',
                 'https://github.com/rktjmp/hotpot.nvim', hotpot_path})
end

-- TODO: ERASEME
-- vim.cmd[[autocmd BufWritePost plugins.lua PackerCompile]]
-- require('plugins')

-- local local_package_path = "./?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?.lua;/Users/cassin/.config/nvim/lua5.1/share/lua/5.1/?/init.lua"
-- package.path = package.path..';'..local_package_path

require('hotpot')
require('init')
